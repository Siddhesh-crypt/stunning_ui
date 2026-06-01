#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

// ImageFilter.shader contract: the FIRST uniform must be a vec2 (auto-bound to
// the layer size) and at least one sampler must be present (auto-bound to the
// backdrop content). The float uniforms in between are set from Dart starting
// at index 2.
uniform vec2  uSize;        // 0,1  (auto: layer size)
uniform float uRadius;      // 2    corner radius (px)
uniform float uRefraction;  // 3    edge displacement (px)
uniform float uGlow;        // 4    specular intensity
uniform vec3  uTint;        // 5,6,7
uniform float uTintAmount;  // 8
uniform sampler2D uTexture; // (auto: the backdrop)

out vec4 fragColor;

float sdRoundRect(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + vec2(r);
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 halfSize = uSize * 0.5;
  vec2 p = fragCoord - halfSize;

  float d = sdRoundRect(p, halfSize, uRadius);

  // SDF normal (numerical) — points outward from the panel.
  float dx = sdRoundRect(p + vec2(1.5, 0.0), halfSize, uRadius)
           - sdRoundRect(p - vec2(1.5, 0.0), halfSize, uRadius);
  float dy = sdRoundRect(p + vec2(0.0, 1.5), halfSize, uRadius)
           - sdRoundRect(p - vec2(0.0, 1.5), halfSize, uRadius);
  vec2 n = normalize(vec2(dx, dy) + 1e-6);

  // Glass is "thickest" at the rim: displacement fades toward the centre.
  float edge = max(halfSize.x, halfSize.y) * 0.5;
  float rim = 1.0 - smoothstep(0.0, edge, -d);

  // Refract: pull the sampled backdrop inward along the normal near the rim.
  vec2 refracted = fragCoord - n * rim * uRefraction;
  vec2 ruv = clamp(refracted / uSize, 0.0, 1.0);

  // Light frost: small cross blur of the refracted backdrop.
  float br = 2.0 / max(uSize.x, uSize.y);
  vec3 col = texture(uTexture, ruv).rgb;
  col += texture(uTexture, clamp(ruv + vec2(br, 0.0), 0.0, 1.0)).rgb;
  col += texture(uTexture, clamp(ruv + vec2(-br, 0.0), 0.0, 1.0)).rgb;
  col += texture(uTexture, clamp(ruv + vec2(0.0, br), 0.0, 1.0)).rgb;
  col += texture(uTexture, clamp(ruv + vec2(0.0, -br), 0.0, 1.0)).rgb;
  col /= 5.0;

  // Brand tint + specular rim highlight.
  col = mix(col, uTint, uTintAmount);
  vec2 lightDir = normalize(vec2(-0.5, -0.85));
  float spec = pow(max(dot(n, lightDir), 0.0), 3.0) * rim * uGlow;
  col += vec3(spec);

  fragColor = vec4(col, 1.0);
}
