#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D depthtex1;

uniform mat4 gbufferProjectionInverse;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec4 screenPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  color = texture(gtexture, texcoord) * glcolor;
  color *= texture(lightmap, lmcoord);

  vec2 screenCoord = (screenPos.xy / screenPos.w) * 0.5 + 0.5;

  float groundDepth = texture(depthtex1, screenCoord).r;
  float waterDepth = screenPos.z / screenPos.w * 0.5 + 0.5;

  float depth = clamp((groundDepth - waterDepth) * 100.0, 0.0, 1.0);

  vec3 shallowColor = vec3(0.2, 0.5, 0.6);
  vec3 deepColor = vec3(0.0, 0.15, 0.3);
  color.rgb = mix(color.rgb, mix(shallowColor, deepColor, depth), 0.5);

  color.a = mix(0.75, 0.9, depth);

  if (color.a < 0.05) {
    discard;
  }
}