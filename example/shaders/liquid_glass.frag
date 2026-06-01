#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

// --- uniforms (set by GlassPainter in declaration order) ---
uniform vec2  uSize;        // 0,1   canvas size in px
uniform float uTime;        // 2     seconds, for the drifting background
uniform vec4  uGlassRect;   // 3,4,5,6  left, top, width, height (px)
uniform float uRadius;      // 7     corner radius (px)
uniform float uRefraction;  // 8     max edge displacement (px) — style driven
uniform float uBlur;        // 9     frost blur radius (px) — style driven
uniform float uGlow;        // 10    glow / specular intensity — style driven
uniform vec3  uTint;        // 11,12,13  brand tint (rgb 0..1)
uniform float uTintAmount;  // 14    how much tint to mix in

out vec4 fragColor;

// Procedural, SHARP background. We keep it a pure function so the glass can
// re-sample it at displaced coordinates to fake real refraction.
vec3 background(vec2 uv) {
  vec3 top    = vec3(0.06, 0.05, 0.16);
  vec3 bottom = vec3(0.02, 0.09, 0.20);
  vec3 col = mix(top, bottom, clamp(uv.y, 0.0, 1.0));

  // two slow-drifting glow blobs
  vec2 b1 = vec2(0.26 + 0.03 * sin(uTime * 0.5), 0.30);
  vec2 b2 = vec2(0.78, 0.70 + 0.03 * cos(uTime * 0.4));
  col += vec3(0.42, 0.10, 0.58) * 0.55 * exp(-12.0 * dot(uv - b1, uv - b1));
  col += vec3(0.05, 0.48, 0.58) * 0.55 * exp(-14.0 * dot(uv - b2, uv - b2));

  // grid lines — these visibly BEND through the glass, which is what sells refraction
  vec2 cell = fract(uv * 14.0);
  vec2 dl = min(cell, 1.0 - cell);
  float lineDist = min(dl.x, dl.y);
  float line = 1.0 - smoothstep(0.0, 0.02, lineDist);
  col += vec3(0.16, 0.20, 0.30) * line;

  return col;
}

// Signed distance to a rounded rectangle.
float sdRoundRect(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + vec2(r);
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;

  vec2 center   = uGlassRect.xy + uGlassRect.zw * 0.5;
  vec2 halfSize = uGlassRect.zw * 0.5;
  vec2 p = fragCoord - center;

  float d = sdRoundRect(p, halfSize, uRadius);
  vec3 sharp = background(uv);

  // numerical SDF normal
  float dx = sdRoundRect(p + vec2(1.5, 0.0), halfSize, uRadius)
           - sdRoundRect(p - vec2(1.5, 0.0), halfSize, uRadius);
  float dy = sdRoundRect(p + vec2(0.0, 1.5), halfSize, uRadius)
           - sdRoundRect(p - vec2(0.0, 1.5), halfSize, uRadius);
  vec2 n = normalize(vec2(dx, dy) + 1e-6);

  // rim: 1 at the edge, fading to 0 toward the center (glass is "thickest" at the rim)
  float edgeWidth = max(halfSize.x, halfSize.y) * 0.6;
  float rim = 1.0 - smoothstep(0.0, edgeWidth, -d);

  // refraction: pull the sample inward along the normal, strongest at the rim
  vec2 refracted = fragCoord - n * rim * uRefraction;
  vec2 ruv = refracted / uSize;

  // cheap 9-tap frost blur of the refracted background
  float br = uBlur / max(uSize.x, uSize.y);
  vec3 g = vec3(0.0);
  g += background(ruv + vec2(-br, -br));
  g += background(ruv + vec2(0.0, -br));
  g += background(ruv + vec2( br, -br));
  g += background(ruv + vec2(-br, 0.0));
  g += background(ruv);
  g += background(ruv + vec2( br, 0.0));
  g += background(ruv + vec2(-br,  br));
  g += background(ruv + vec2(0.0,  br));
  g += background(ruv + vec2( br,  br));
  g /= 9.0;

  // subtle frost lift + brand tint
  g += 0.04;
  g = mix(g, uTint, uTintAmount);

  // specular highlight near the rim
  vec2 lightDir = normalize(vec2(-0.5, -0.85));
  float spec = pow(max(dot(n, lightDir), 0.0), 3.0) * rim * uGlow;
  g += vec3(spec);

  // antialiased inside mask
  float inside = 1.0 - smoothstep(-1.0, 1.0, d);
  vec3 col = mix(sharp, g, inside);

  // glowing 1-2px border stroke
  float border = 1.0 - smoothstep(0.0, 2.0, abs(d));
  col += uTint * border * (0.45 + uGlow);

  fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
