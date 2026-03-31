#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

layout(location = 0) out vec4 color;

void main() {
  color = texture(colortex0, texcoord);
  color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

  // vignette
  vec2 centeredCoord = texcoord - 0.5;
  float dist = length(centeredCoord);
  float vignette = smoothstep(0.9, 0.3, dist);  
  color.rgb *= vignette;
}