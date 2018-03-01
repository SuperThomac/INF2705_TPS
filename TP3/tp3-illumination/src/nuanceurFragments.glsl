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

uniform sampler2D laTexture;

/////////////////////////////////////////////////////////////////

in Attribs {
   vec4 couleur;
   vec3 normale;
} AttribsIn;

out vec4 FragColor;

float calculerSpot( in vec3 spotDir, in vec3 L )
{
   return( 0.0 );
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
  float reflectivity = 0;

  if (utiliseBlinn) {
    // Blinn
    vec3 B = normalize(L + O);
    reflectivity = max(dot(B, N), 0.0);
  } else {
    // Phong
    vec3 R = reflect(-L, N); // réflexion de L par rapport à N
    // produit scalaire pour la réflexion spéculaire (Phong)
    reflectivity = max(dot(R, O), 0.0);
  }
  return (pow(reflectivity, FrontMaterial.shininess));
}

void main( void )
{
   // ...

   // assigner la couleur finale
   //FragColor = AttribsIn.couleur;
   FragColor = vec4( 0.5, 0.5, 0.5, 1.0 ); // gris moche!

   // vec4 coul = calculerReflexion( L, N, O );
   // ...
   vec3 L = normalize(AttribsIn.lumiDir);

   if (typeIllumination != 1) {

	float LdotN = dot(L, AttribsIn.normale); // produit scalaire L.N (source Lumineuse, Normale)
	
    // calcul de la composante diffuse
    vec4 coul = FrontMaterial.diffuse * LightSource[0].diffuse * LdotN;
    
    // calcul de la composante spéculaire
    vec3 O = normalize(AttribsIn.obsVec); // vecteur observateur

    coul += FrontMaterial.specular * LightSource[0].specular *
            calculerReflexion(L, AttribsIn.normale, O);
	}
   vec3 test = (AttribsIn.normale);
   if ( afficheNormales ) FragColor = vec4( test,1.0);
}
