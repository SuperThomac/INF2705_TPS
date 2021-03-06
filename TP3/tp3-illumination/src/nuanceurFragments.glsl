#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   vec4 position;      // dans le repère du monde
   vec3 spotDirection; // dans le repère du monde
   float spotExponent;
   float spotAngleOuverture; // ([0.0,90.0] ou 180.0)
   float constantAttenuation;
   float linearAttenuation;
   float quadraticAttenuation;
} LightSource[1];

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
   vec4 emission;
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
   vec4 ambient;       // couleur ambiante
   bool localViewer;   // observateur local ou à l'infini?
   bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

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

uniform mat4 matrVisu;
uniform sampler2D laTexture;
const int ILLUMINATION_LAMBERT = 0;
const int ILLUMINATION_GOURAUD = 1;
const int ILLUMINATION_PHONG = 2;
const int TEXEL_OPAQUE = 1;
const int TEXEL_TRANSPARENT = 2;
float c1 = LightSource[0].constantAttenuation;
float c2 = LightSource[0].linearAttenuation;
float c3 = LightSource[0].quadraticAttenuation;


/////////////////////////////////////////////////////////////////

in Attribs {
   vec4 couleur;
   vec3 normale;
   vec3 lumDir;
   vec3 obsVec;
   float distLum;
   vec2 textureCoord;
} AttribsIn;

out vec4 FragColor;

float calculerSpot( in vec3 spotDir, in vec3 L )
{
   spotDir = normalize(spotDir);
   float cosGamma = dot(spotDir, L);
   float innerCos = cos(radians(LightSource[0].spotAngleOuverture));

   if(utiliseDirect) {
      // Spot Direct3D
      float outerCos = pow(innerCos, 1.01 + LightSource[0].spotExponent / 2);
      return smoothstep(outerCos, innerCos, cosGamma);
   } else {
      // Spot OpenGL
      if(cosGamma >= innerCos) {
		  return pow(cosGamma, LightSource[0].spotExponent);
	  }
}
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O, in float distLum ) {
   vec4 couleur = vec4(0);
   float NdotL = dot(N, L); // calcul de Normale.DirectionLumière pour reflexion diffuse
   if ( NdotL > 0.0 ) { // on calcul l'éclairage seulement si le scalaire est positif
      float facteurAttenuation = min(1.0, 1/(c1 + c2 * distLum + c3 * pow(distLum,2)));
      couleur += facteurAttenuation * FrontMaterial.diffuse * LightSource[0].diffuse * NdotL; // calcul la composante diffuse ( toute reflexion)
      float facteurReflexion = 0.0;
      if (utiliseBlinn) {  // Blinn
         vec3 B = normalize(L + O); // calcul bissectrice entre la directionLumière et l'observateur (aussi appele half vector ou HF)
         facteurReflexion = max( dot(L, N), 0.0 ); 
         
      } else { // Phong
         vec3 R = reflect(-L, N); // réflexion de L par rapport à N
         facteurReflexion = max( dot(R, O), 0.0 );
      }
      couleur += facteurAttenuation * FrontMaterial.specular * LightSource[0].specular * pow( facteurReflexion, FrontMaterial.shininess ); // calcul composante speculaire
      couleur += (FrontMaterial.emission + FrontMaterial.ambient * LightModel.ambient) + LightSource[0].ambient * FrontMaterial.ambient; // calcul composante ambiante 
   }

   return clamp( couleur, 0.0, 1.0 );
}

void main( void )
{
   vec3 L = normalize(AttribsIn.lumDir);
   vec3 N = normalize(AttribsIn.normale); // ici normale différente selon Lambert ou Phong
   vec3 O = normalize(AttribsIn.obsVec);
   vec3 spotDir = transpose(inverse(mat3(matrVisu))) * (-LightSource[0].spotDirection);
   
   vec4 tex = texture(laTexture, AttribsIn.texCoord);
   if (texnumero != 0) { // si on utilise une texture
      FragColor = texture(laTexture, AttribsIn.textureCoord).rgba;
      if (afficheTexelFonce == TEXEL_OPAQUE) {
         FragColor += vec4(1);
         FragColor /= 2;
      } else if (afficheTexelFonce == TEXEL_TRANSPARENT && (FragColor.r + FragColor.g + FragColor.b) / 3 < 0.01) {
         discard;
      }
  } else {
    FragColor = vec4(1);
  }
  
  if ( typeIllumination == ILLUMINATION_GOURAUD) { 
	  // si Gouraud on utilise la couleur interpolée
         FragColor *=  AttribsIn.couleur * calculerSpot(spotDir, L);
   } else { 
	  // si Lambert ou Phong on calcule la reflexion à partir de de L,N,O
      vec4 coul = calculerReflexion( L, N, O, AttribsIn.distLum );
      FragColor *= coul * calculerSpot(spotDir, L); 
    }
   if ( afficheNormales ) FragColor = vec4(N ,1.0);
}
