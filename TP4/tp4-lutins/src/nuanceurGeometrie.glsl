#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 matrProj;
//uniform int pointSize;
uniform int texnumero;


in Attribs {
	vec4 couleur;
	float tempsRestant;
	float sens; // du vol
	vec2 texCoord;
} AttribsIn[];

out Attribs {
	vec4 couleur;
	vec2 texCoord;
} AttribsOut;

void main()
{
	vec2 coinsTex[4];
	
	coinsTex[0] = vec2( -0.5,  0.5 );
	coinsTex[1] = vec2( -0.5, -0.5 );
	coinsTex[2] = vec2(  0.5,  0.5 );
	coinsTex[3] = vec2(  0.5, -0.5 );
   
   
   gl_PointSize = 5.0; // en pixels
   float fact = 0.025 * gl_PointSize;
   
   mat2 matrRotation = mat2(1, 0, 0, 1);
   if (texnumero == 1){
	   float s = sin(4.0 * AttribsIn[0].tempsRestant);
		float c = cos(4.0 * AttribsIn[0].tempsRestant);
		matrRotation = mat2(c, -s, s, c);
   }
   
   vec2 atlas = vec2(16 * AttribsIn[0].sens,1);
   vec2 decalage = vec2(int(20.0 * AttribsIn[0].tempsRestant) % 16, 0);
   
   
   for (int i=0; i<4; i++){
		vec4 pos = vec4(gl_in[0].gl_Position.xy + matrRotation * fact * coinsTex[i], gl_in[0].gl_Position.zw);
		gl_Position = matrProj * pos;
		AttribsOut.couleur = AttribsIn[0].couleur;
		switch (texnumero) {
			case 2:
			case 3:
			AttribsOut.texCoord = (coinsTex[i] + vec2(0.5, 0.5) + decalage)/atlas;
			break;
			default:
			AttribsOut.texCoord = (coinsTex[i] + vec2(0.5, 0.5));
			break;
		}	
		EmitVertex();
	}
}
