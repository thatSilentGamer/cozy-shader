#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

 // This constant can be placed anywhere - but placing it in shadow.fsh makes the most sense.
 // It's a special constant recognized by Iris that will determine the resolution of the shadow map!
 const int shadowMapResolution = 2048;

layout(location = 0) out vec4 color;

void main() {
  color = texture(gtexture, texcoord) * glcolor;
  if (color.a < 0.1){
    discard;
  }
}