#version 330 compatibility
#include "/lib/shadowDistort.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

/*
const int colortex0Format = RGB16;
*/

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float sunAngle;

const vec3 blocklightColor = vec3(1.0, 0.35, 0.04);
const vec3 skylightColor = vec3(0.04, 0.1, 0.2);
const vec3 sunlightColor = vec3(1.0, 0.85, 0.6);
const vec3 ambientColor = vec3(0.08, 0.06, 0.05);

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

vec3 getSunsetColor() {
  float sunriseFactor = smoothstep(0.65, 0.75, sunAngle) - smoothstep(0.75, 0.85, sunAngle);
  float sunsetFactor = smoothstep(0.15, 0.25, sunAngle) - smoothstep(0.25, 0.35, sunAngle);
  float factor = clamp(sunriseFactor + sunsetFactor, 0.0, 1.0);
  return mix(vec3(1.0), vec3(1.0, 0.4, 0.15), factor);
}

vec3 getShadow(vec3 shadowScreenPos){
  float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
  if (transparentShadow == 1.0){
    return vec3(1.0);
  }
  float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
  if(opaqueShadow == 0.0){
    return vec3(0.0);
  }
  vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
  return shadowColor.rgb * (1.0 - shadowColor.a);
}

void main() {
  vec2 lightmap = texture(colortex1, texcoord).xy;
  vec3 encodedNormal = texture(colortex2, texcoord).rgb;
  vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
  vec3 lightVector = normalize(shadowLightPosition);
  vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

  color = texture(colortex0, texcoord);
  color.rgb = pow(color.rgb, vec3(2.2));

  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }

  vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
  vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
  shadowClipPos.z -= 0.001;
  shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
  vec3 shadowNdcPos = shadowClipPos.xyz / shadowClipPos.w;
  vec3 shadowScreenPos = shadowNdcPos * 0.5 + 0.5;

  vec3 shadow = getShadow(shadowScreenPos);

  vec3 blocklight = lightmap.x * blocklightColor;
  vec3 skylight = lightmap.y * skylightColor;
  vec3 ambient = ambientColor;
  vec3 sunlight = sunlightColor * getSunsetColor() * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;

  color.rgb *= blocklight + skylight + ambient + sunlight;
}