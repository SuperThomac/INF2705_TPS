#version 410

uniform sampler2D laTexture;
uniform int texnumero;

const int texEtincelle = 1;
const int texOiseau = 2;
const int texLeprechaun = 3;

in Attribs {
   vec4 couleur;
   vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

void main( void )
{

    AttribsIn.couleur;
   if ( texnumero > 0 ){ // pas de texture
      vec4 texel = texture(laTexture, AttribsIn.texCoord).rgba;
      if (texel.a < 0.1) discard; // pour enlever la partie de la texture non désiré
      FragColor = mix(AttribsIn.couleur, texel, 0.7);
   }
   else{
	      FragColor = AttribsIn.couleur;
	}
}
