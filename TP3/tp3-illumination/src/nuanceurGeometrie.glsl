#version 410

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
const int ILLUMINATION_LAMBERT = 0;
const int ILLUMINATION_GOURAUD = 1;
const int ILLUMINATION_PHONG = 2;
layout (std140) uniform varsUnif
{
   // partie 1: illumination
   int typeIllumination;     // 0:Lambert, 1:Gouraud, 2:Phong
   bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
   bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
   bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
   // partie 3: texture
   int texnumero;            // numéro de la texture appliquée
   bool utiliseCouleur;      // doit-on utiliser la couleur de base de l'objet en plus de celle de la texture?
   int afficheTexelFonce;    // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
};

in Attribs {
   vec4 couleur;
   vec3 normale;
   vec3 lumDir;
   vec3 obsVec;
} AttribsIn[];

out Attribs {
   vec4 couleur;
   vec3 normale;
   vec3 lumDir;
   vec3 obsVec;
} AttribsOut;

void main()
{
   if( typeIllumination == ILLUMINATION_LAMBERT  ) { // calcul de la normale à la surface pour Lambert
      vec3 N = vec3(0);
      vec3 P0 = gl_in[0].gl_Position.xyz; 
      vec3 P1 = gl_in[1].gl_Position.xyz;
      vec3 P2 = gl_in[2].gl_Position.xyz;
      // calcul des vecteurs directeurs du plan triangle
      vec3 V0 = P1 - P0; 
      vec3 V1 = P2 - P0;
      N = normalize(cross(V0, V1));
      for (int i = 0; i < gl_in.length(); ++i) {
         AttribsOut.normale = N;
         gl_Position = gl_in[i].gl_Position;
         AttribsOut.couleur = AttribsIn[i].couleur;
         AttribsOut.lumDir = AttribsIn[i].lumDir;
         AttribsOut.obsVec = AttribsIn[i].obsVec;
         EmitVertex();
      }
  }
   for (int i = 0; i < gl_in.length(); ++i) {
      AttribsOut.normale = AttribsIn[i].normale;
      gl_Position = gl_in[i].gl_Position;
      AttribsOut.couleur = AttribsIn[i].couleur;
      AttribsOut.lumDir = AttribsIn[i].lumDir;
      AttribsOut.obsVec = AttribsIn[i].obsVec;
      EmitVertex();
   }
}
