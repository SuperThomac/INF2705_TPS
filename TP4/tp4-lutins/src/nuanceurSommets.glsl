#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;

in float tempsRestant;
in vec3 vitesse;

out Attribs {
   vec4 couleur;
   float tempsRestant;
   float sens; // du vol
   vec2 texCoord;
} AttribsOut;

void main( void )
{
   gl_Position = matrVisu * matrModel * Vertex;

   AttribsOut.tempsRestant = tempsRestant;

   // couleur du sommet
   AttribsOut.couleur = Color;
   AttribsOut.sens = sign((matrVisu * matrModel * vec4(vitesse,1)).x);
}
