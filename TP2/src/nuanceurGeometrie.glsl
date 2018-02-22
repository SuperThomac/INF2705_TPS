#version 410

layout(triangles) in;
layout(triangle_strip, max_vertices = 8) out;

in Attribs {
   vec4 couleur;
   float clipDistance;
} AttribsIn[];

out Attribs {
   vec4 couleur;
} AttribsOut;
	
void main()
{
   for ( int i = 0 ; i < gl_in.length() ; ++i ) // cloture du bas
   {
      gl_ViewportIndex = 0;
      gl_Position = gl_in[i].gl_Position;
      gl_ClipDistance[0] = -AttribsIn[i].clipDistance;
      AttribsOut.couleur = AttribsIn[i].couleur;
      
      EmitVertex();
   }
   EndPrimitive();

   for ( int i = 0 ; i < gl_in.length() ; ++i ) // cloture du haut
   {
      gl_ViewportIndex = 1;
      gl_Position = gl_in[i].gl_Position;
      gl_ClipDistance[0] = AttribsIn[i].clipDistance;
      AttribsOut.couleur = AttribsIn[i].couleur;
      EmitVertex();
   }
   EndPrimitive();
}
