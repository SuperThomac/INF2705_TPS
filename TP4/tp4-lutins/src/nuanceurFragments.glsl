#version 410

uniform sampler2D laTexture;
uniform int texnumero;

in Attribs {
   vec4 couleur;
   vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

void main( void )
{

   // Mettre un test bidon afin que l'optimisation du compilateur n'élimine l'attribut "couleur".
   // Vous MODIFIEREZ ce test inutile!
   if ( AttribsIn.couleur.r < 0.0 ) discard;

   //FragColor = texture( laTexture, gl_PointCoord );
    AttribsIn.couleur;
   if ( texnumero > 0 )
   {
      vec4 texel = texture(laTexture, AttribsIn.texCoord).rgba;
      if (texel.a < 0.1) discard;
      FragColor = mix(AttribsIn.couleur, texel, 0.7);
   }
   else
   {
	      FragColor = AttribsIn.couleur;
	}
}
