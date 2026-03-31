#version 330 compatibility

uniform float frameTimeCounter;
uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec4 screenPos;

void main() {
  vec4 worldPos = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

  vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
  if (normal.y > 0.7) {
    float wave = sin(worldPos.x * 2.0 + frameTimeCounter * 2.0) * 0.05
               + sin(worldPos.z * 2.0 + frameTimeCounter * 1.5) * 0.05
               + sin((worldPos.x + worldPos.z) * 1.5 + frameTimeCounter * 2.5) * 0.03;
    worldPos.y += wave;
  }

  gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * worldPos;
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
  screenPos = gl_Position;
}
