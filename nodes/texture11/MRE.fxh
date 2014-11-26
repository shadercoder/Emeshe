/*
channels:
0 Color			R	G	B
1 ViewPosition	X	Y	Z
2 WorldPosition	X	Y	Z
3 ViewNormals	X	Y	Z
4 WorldNormals	X	Y	Z
5 Velocity		X 	Y	Z
6 Material		U	V	MatID	ObjID
7 DepthStencil	D	S
*/
Texture2D Chns[8] <string uiname="Channels";>;

#define MRE_COLOR 0
#define MRE_VIEWPOS 1
#define MRE_WORLDPOS 2
#define MRE_VIEWNORM 3
#define MRE_WORLDNORM 4
#define MRE_VELOCITY 5
#define MRE_MATERIAL 6
#define MRE_DEPTHSTENCIL 7
#define MRE_MAT_UV xy
#define MRE_MAT_OBJID w
#define MRE_MATID z

//Sample
float3 mre_getcolor(SamplerState s0, float2 uv) {return Chns[MRE_COLOR].Sample(s0,uv).xyz;}
float3 mre_getviewpos(SamplerState s0, float2 uv) {return Chns[MRE_VIEWPOS].Sample(s0,uv).xyz;}
float3 mre_getworldpos(SamplerState s0, float2 uv) {return Chns[MRE_WORLDPOS].Sample(s0,uv).xyz;}
float3 mre_getviewnorm(SamplerState s0, float2 uv) {return Chns[MRE_VIEWNORM].Sample(s0,uv).xyz;}
float3 mre_getworldnorm(SamplerState s0, float2 uv) {return Chns[MRE_WORLDNORM].Sample(s0,uv).xyz;}
float3 mre_getvelocity(SamplerState s0, float2 uv) {return Chns[MRE_VELOCITY].Sample(s0,uv).xyz;}
float2 mre_getuv(SamplerState s0, float2 uv) {return Chns[MRE_MATERIAL].Sample(s0,uv).MRE_MAT_UV;}
float mre_getobjid(SamplerState s0, float2 uv) {return Chns[MRE_MATERIAL].Sample(s0,uv).MRE_MAT_OBJID;}
float mre_getmatid(SamplerState s0, float2 uv) {return Chns[MRE_MATERIAL].Sample(s0,uv).MRE_MATID;}
float2 mre_getdepthstencil(SamplerState s0, float2 uv) {return Chns[MRE_DEPTHSTENCIL].Sample(s0,uv).xy;}
//SampleLevel
float3 mre_getcolor(SamplerState s0, float2 uv, float lod) {return Chns[MRE_COLOR].SampleLevel(s0,uv,lod).xyz;}
float3 mre_getviewpos(SamplerState s0, float2 uv, float lod) {return Chns[MRE_VIEWPOS].SampleLevel(s0,uv,lod).xyz;}
float3 mre_getworldpos(SamplerState s0, float2 uv, float lod) {return Chns[MRE_WORLDPOS].SampleLevel(s0,uv,lod).xyz;}
float3 mre_getviewnorm(SamplerState s0, float2 uv, float lod) {return Chns[MRE_VIEWNORM].SampleLevel(s0,uv,lod).xyz;}
float3 mre_getworldnorm(SamplerState s0, float2 uv, float lod) {return Chns[MRE_WORLDNORM].SampleLevel(s0,uv,lod).xyz;}
float3 mre_getvelocity(SamplerState s0, float2 uv, float lod) {return Chns[MRE_VELOCITY].SampleLevel(s0,uv,lod).xyz;}
float2 mre_getuv(SamplerState s0, float2 uv, float lod) {return Chns[MRE_MATERIAL].SampleLevel(s0,uv,lod).MRE_MAT_UV;}
float mre_getobjid(SamplerState s0, float2 uv, float lod) {return Chns[MRE_MATERIAL].SampleLevel(s0,uv,lod).MRE_MAT_OBJID;}
float mre_getmatid(SamplerState s0, float2 uv, float lod) {return Chns[MRE_MATERIAL].SampleLevel(s0,uv,lod).MRE_MATID;}
float2 mre_getdepthstencil(SamplerState s0, float2 uv, float lod) {return Chns[MRE_DEPTHSTENCIL].SampleLevel(s0,uv,lod).xy;}

// Material Features
#define MF_LIGHTING_AMBIENT 0x1
#define MF_LIGHTING_PHONG 0x2
#define MF_LIGHTING_PHONG_SPECULARMAP 0x4
#define MF_LIGHTING_COOKTORRANCE 0x8
#define MF_LIGHTING_COOKTORRANCE_BAKED 0x10
#define MF_LIGHTING_COOKTORRANCE_GLOSSMAP 0x20
#define MF_LIGHTING_FAKESSS 0x40
#define MF_LIGHTING_FAKESSS_MAP 0x80
#define MF_LIGHTING_FAKERIMLIGHT 0x100
#define MF_LIGHTING_MATCAP 0x200
#define MF_LIGHTING_EMISSION 0x400
#define MF_LIGHTING_EMISSION_MAP 0x800
#define MF_GI_SSAO 0x1000
#define MF_GI_CSSGI 0x2000
#define MF_GI_SSSSS 0x4000
#define MF_GI_SSSSS_MAP 0x8000
#define MF_REFLECTION_SPHEREMAP 0x10000
#define MF_REFLECTION_SSR 0x20000
#define MF_REFLECTION_MAP 0x40000
#define MF_REFRACTION_SPHEREMAP 0x80000
#define MF_REFRACTION_SSR 0x100000
#define MF_REFRACTION_MAP 0x200000

bool CheckFeature(uint Features, uint Filter)
{
	return (Features & Filter) == Filter;
}
bool CheckFeature(uint2 Features, uint2 Filter)
{
	bool p1 = (Features.x & Filter.x) == Filter.x;
	bool p2 = (Features.y & Filter.y) == Filter.y;
	return p1 || p2;
}
uint FeatureFlag(uint FeatureID)
{
	return pow(2, FeatureID);
}

// Feature Parameters
#define MF_LIGHTING_AMBIENT_AMBIENTCOLOR_SIZE 3
#define MF_LIGHTING_AMBIENT_AMBIENTCOLOR_OFFSET 0
#define MF_LIGHTING_PHONG_SPECULARCOLOR_SIZE 3
#define MF_LIGHTING_PHONG_SPECULARCOLOR_OFFSET 0
#define MF_LIGHTING_PHONG_SPECULARPOWER_SIZE 1
#define MF_LIGHTING_PHONG_SPECULARPOWER_OFFSET 3
#define MF_LIGHTING_PHONG_SPECULARSTRENGTH_SIZE 1
#define MF_LIGHTING_PHONG_SPECULARSTRENGTH_OFFSET 4
#define MF_LIGHTING_PHONG_ATTENUATION_SIZE 3
#define MF_LIGHTING_PHONG_ATTENUATION_OFFSET 5
#define MF_LIGHTING_PHONG_SPECULARMAP_MAPID_SIZE 1
#define MF_LIGHTING_PHONG_SPECULARMAP_MAPID_OFFSET 0
#define MF_LIGHTING_COOKTORRANCE_SPECULARCOLOR_SIZE 3
#define MF_LIGHTING_COOKTORRANCE_SPECULARCOLOR_OFFSET 0
#define MF_LIGHTING_COOKTORRANCE_SPECULARSTRENGTH_SIZE 1
#define MF_LIGHTING_COOKTORRANCE_SPECULARSTRENGTH_OFFSET 3
#define MF_LIGHTING_COOKTORRANCE_ROUGHNESS_SIZE 1
#define MF_LIGHTING_COOKTORRANCE_ROUGHNESS_OFFSET 4
#define MF_LIGHTING_COOKTORRANCE_REFLECTANCE_SIZE 1
#define MF_LIGHTING_COOKTORRANCE_REFLECTANCE_OFFSET 5
#define MF_LIGHTING_COOKTORRANCE_BAKED_BAKEDID_SIZE 1
#define MF_LIGHTING_COOKTORRANCE_BAKED_BAKEDID_OFFSET 0
#define MF_LIGHTING_COOKTORRANCE_GLOSSMAP_MAPID_SIZE 1
#define MF_LIGHTING_COOKTORRANCE_GLOSSMAP_MAPID_OFFSET 0
#define MF_LIGHTING_FAKESSS_STRENGTH_SIZE 1
#define MF_LIGHTING_FAKESSS_STRENGTH_OFFSET 0
#define MF_LIGHTING_FAKESSS_POWER_SIZE 1
#define MF_LIGHTING_FAKESSS_POWER_OFFSET 1
#define MF_LIGHTING_FAKESSS_THICKNESS_SIZE 1
#define MF_LIGHTING_FAKESSS_THICKNESS_OFFSET 2
#define MF_LIGHTING_FAKESSS_COEFFICIENT_SIZE 3
#define MF_LIGHTING_FAKESSS_COEFFICIENT_OFFSET 3
#define MF_LIGHTING_FAKESSS_MAP_MAPID_SIZE 1
#define MF_LIGHTING_FAKESSS_MAP_MAPID_OFFSET 0
#define MF_LIGHTING_FAKERIMLIGHT_STRENGTH_SIZE 1
#define MF_LIGHTING_FAKERIMLIGHT_STRENGTH_OFFSET 0
#define MF_LIGHTING_FAKERIMLIGHT_POWER_SIZE 1
#define MF_LIGHTING_FAKERIMLIGHT_POWER_OFFSET 1
#define MF_LIGHTING_MATCAP_MAPID_SIZE 1
#define MF_LIGHTING_MATCAP_MAPID_OFFSET 0
#define MF_LIGHTING_MATCAP_TRANSFORM_SIZE 16
#define MF_LIGHTING_MATCAP_TRANSFORM_OFFSET 1
#define MF_LIGHTING_EMISSION_COLOR_SIZE 3
#define MF_LIGHTING_EMISSION_COLOR_OFFSET 0
#define MF_LIGHTING_EMISSION_STRENGTH_SIZE 1
#define MF_LIGHTING_EMISSION_STRENGTH_OFFSET 3
#define MF_LIGHTING_EMISSION_MAP_MAPID_SIZE 1
#define MF_LIGHTING_EMISSION_MAP_MAPID_OFFSET 0
#define MF_GI_SSAO_AMOUNTMUL_SIZE 1
#define MF_GI_SSAO_AMOUNTMUL_OFFSET 0
#define MF_GI_CSSGI_AMOUNTMUL_SIZE 1
#define MF_GI_CSSGI_AMOUNTMUL_OFFSET 0
#define MF_GI_CSSGI_RADIUSMUL_SIZE 1
#define MF_GI_CSSGI_RADIUSMUL_OFFSET 1
#define MF_GI_SSSSS_AMOUNTMUL_SIZE 1
#define MF_GI_SSSSS_AMOUNTMUL_OFFSET 0
#define MF_GI_SSSSS_RADIUSMUL_SIZE 1
#define MF_GI_SSSSS_RADIUSMUL_OFFSET 1
#define MF_GI_SSSSS_MAP_MAPID_SIZE 1
#define MF_GI_SSSSS_MAP_MAPID_OFFSET 0
#define MF_REFLECTION_SPHEREMAP_STRENGTH_SIZE 1
#define MF_REFLECTION_SPHEREMAP_STRENGTH_OFFSET 0
#define MF_REFLECTION_SPHEREMAP_FRESNEL_SIZE 1
#define MF_REFLECTION_SPHEREMAP_FRESNEL_OFFSET 1
#define MF_REFLECTION_SPHEREMAP_ENVID_SIZE 1
#define MF_REFLECTION_SPHEREMAP_ENVID_OFFSET 2
#define MF_REFLECTION_SSR_STRENGTH_SIZE 1
#define MF_REFLECTION_SSR_STRENGTH_OFFSET 0
#define MF_REFLECTION_SSR_FRESNEL_SIZE 1
#define MF_REFLECTION_SSR_FRESNEL_OFFSET 1
#define MF_REFLECTION_SSR_BLUR_SIZE 1
#define MF_REFLECTION_SSR_BLUR_OFFSET 2
#define MF_REFLECTION_MAP_MAPID_SIZE 1
#define MF_REFLECTION_MAP_MAPID_OFFSET 0
#define MF_REFRACTION_SPHEREMAP_STRENGTH_SIZE 1
#define MF_REFRACTION_SPHEREMAP_STRENGTH_OFFSET 0
#define MF_REFRACTION_SPHEREMAP_FRESNEL_SIZE 1
#define MF_REFRACTION_SPHEREMAP_FRESNEL_OFFSET 1
#define MF_REFRACTION_SPHEREMAP_ENVID_SIZE 1
#define MF_REFRACTION_SPHEREMAP_ENVID_OFFSET 2
#define MF_REFRACTION_SSR_STRENGTH_SIZE 1
#define MF_REFRACTION_SSR_STRENGTH_OFFSET 0
#define MF_REFRACTION_SSR_FRESNEL_SIZE 1
#define MF_REFRACTION_SSR_FRESNEL_OFFSET 1
#define MF_REFRACTION_SSR_BLUR_SIZE 1
#define MF_REFRACTION_SSR_BLUR_OFFSET 2
#define MF_REFRACTION_MAP_MAPID_SIZE 1
#define MF_REFRACTION_MAP_MAPID_OFFSET 0
