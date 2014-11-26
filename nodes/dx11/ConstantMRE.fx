//@author: microdee

#import "MREForward.fxh"

Texture2D DiffTex;
Texture2D BumpTex;
StructuredBuffer<sDeferredBase> InstancedParams;

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tV : VIEW;
	float4x4 tVI : VIEWINVERSE;
	float4x4 ptV : PREVIOUSVIEW;
	float4x4 tP : PROJECTION;
	float4x4 ptP : PREVIOUSPROJECTION;
	float4x4 tVP : VIEWPROJECTION;
	float4x4 NormTr;
	float gVelocityGain = 1;
	bool isTriPlanar = false;
	float TriPlanarPow = 1;
	float utilalpha = 0;
	bool InstanceFromGeomFX = false;
	bool Instancing = false;
};

cbuffer cbPerObject : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 ptW; // previous frame world transform per draw call
	float4x4 tTex;
	float FDiffAmount = 1;
	float4 FDiffColor <bool color=true;> = 1;
	float alphatest = 0.5;
	float FBumpAmount = 0;
	float bumpOffset = 0;
	int MatID = 0;
	int ObjID = 0;
};

struct VSgvin
{
	float4 PosO : POSITION;
	float3 NormO : NORMAL;
	float2 TexCd : TEXCOORD0;
	float4 velocity : COLOR0;
	uint vid : SV_VertexID;
	uint iid : SV_InstanceID;
};

struct VSin
{
	float4 PosO : POSITION;
	float3 NormO : NORMAL;
	float2 TexCd : TEXCOORD0;
	uint vid : SV_VertexID;
	uint iid : SV_InstanceID;
};

struct vs2gs
{
    float4 PosWVP: SV_Position;
	float4 TexCd: TEXCOORD0;
    float4 PosW: TEXCOORD1;
    float3 NormW: NORMAL;
    nointerpolation float ii: TEXCOORD2;
    float4 vel : COLOR0;
};
struct vs2gsi
{
    float4 PosWVP: SV_Position;
	float4 TexCd: TEXCOORD0;
    float4 PosW: TEXCOORD1;
    nointerpolation float ii: TEXCOORD2;
    float3 NormW: NORMAL;
    float4 vel : COLOR0;
};
/*
struct gs2ps
{
    float4 PosWVP: SV_Position;
	float4 TexCd: TEXCOORD0;
    float4 PosW: TEXCOORD1;
    float3 NormW: NORMAL;
	float4 triPos0 : TEXCOORD2;
	float4 triPos1 : TEXCOORD3;
	float4 triPos2 : TEXCOORD4;
	float3 triNorm0 : TEXCOORD5;
	float3 triNorm1 : TEXCOORD6;
	float3 triNorm2 : TEXCOORD7;
    float4 vel : COLOR0;
};
*/
vs2gsi VSgv(VSgvin In)
{
    // inititalize
    vs2gsi Out = (vs2gsi)0;
	// get Instance ID from GeomFX
	float ii = (Instancing) ? In.iid : In.velocity.w;
	Out.ii = ii;
	
	// TexCoords
	float4x4 tT = (InstanceFromGeomFX || Instancing) ? mul(InstancedParams[ii].tTex,tTex) : tTex;
	
	float4x4 w = (InstanceFromGeomFX || Instancing) ? mul(InstancedParams[ii].tW,tW) : tW;
	
	float4 dispPos = In.PosO;
	float3 dispNorm = In.NormO;
    float3 fViewDirV = -normalize(mul(mul(float4(dispPos.xyz,1),w),tV).xyz);
	//float4 pdispPos = In.PosO;
	
	float4 pdispPos = float4(In.velocity.xyz,1);
	
    Out.NormW = normalize(mul(float4(dispNorm,0), w).xyz);
	
    Out.PosW = mul(dispPos, w);
	
	//if(isTriPlanar) Out.TexCd = float4(TriPlanar(dispPos.xyz, dispNorm, tT, TriPlanarPow),0,1);
	if(isTriPlanar) Out.TexCd = mul(float4(dispPos),tT);
	else Out.TexCd = mul(float4(In.TexCd,0,1), tT);
	
    float4 PosWV = mul(Out.PosW, tV);
    Out.PosWVP = mul(PosWV, tP);
	
	// velocity
	float4x4 pw = (InstanceFromGeomFX|| Instancing) ? mul(InstancedParams[ii].ptW,ptW) : ptW;
	float3 npos = PosWV.xyz;
	float4x4 ptWV = pw;
	ptWV = mul(ptWV, ptV);
	float3 pnpos = mul(pdispPos, ptWV).xyz;
	Out.vel.rgb = ((npos - pnpos) * gVelocityGain);
	Out.vel.rgb += 0.5;
	Out.vel.a = 1;
	
    return Out;
}
vs2gs VS(VSin In)
{
    //inititalize all fields of output struct with 0
    vs2gs Out = (vs2gs)0;
	
	float ii = In.iid;
	Out.ii = ii;
	
	float4 dispPos = In.PosO;
	float3 dispNorm = In.NormO;
	float4 pdispPos = In.PosO;
    float3 fViewDirV = -normalize(mul(mul(float4(dispPos.xyz,1),tW),tV).xyz);
	
	float4x4 tT = (Instancing) ? mul(InstancedParams[ii].tTex,tTex) : tTex;
	
	float4x4 w = (Instancing) ? mul(InstancedParams[ii].tW,tW) : tW;
	
    Out.NormW = normalize(mul(float4(dispNorm,0), w).xyz);
	
    Out.PosW = mul(dispPos, w);
	
	//if(isTriPlanar) Out.TexCd = float4(TriPlanar(dispPos.xyz, dispNorm, tTex, TriPlanarPow),0,1);
	if(isTriPlanar) Out.TexCd = dispPos;
	else Out.TexCd = mul(float4(In.TexCd,0,1), tTex);
	
    float4 PosWV = mul(Out.PosW, tV);
    Out.PosWVP = mul(PosWV, tP);
	//Out.PosW -= float4(Out.NormW*SmoothNormVal,0);
	
	float3 npos = PosWV.xyz;
	
	float4x4 pw = (Instancing) ? mul(InstancedParams[ii].ptW,ptW) : ptW;
	
	float4x4 ptWV = pw;
	ptWV = mul(ptWV, ptV);
	//ptWVP = mul(ptWVP, ptP);
	float3 pnpos = mul(pdispPos, ptWV).xyz;
	Out.vel.rgb = ((npos - pnpos) * gVelocityGain);
	//Out.vel.rgb *= min(3,2/(pnpos.z));
	Out.vel.rgb += 0.5;
	Out.vel.a = 1;
	
    return Out;
}

PSOut PS_Tex(vs2gs In)
{
	
	float ii = In.ii;
	float3 posWb = In.PosW.xyz;

	float4x4 tT = (Instancing) ? mul(InstancedParams[ii].tTex,tTex) : tTex;
	
	PSOut Out = (PSOut)0;
	float3 normWb = In.NormW;
	float2 uvb = float2(0,0);

	uvb = In.TexCd.xy;
	
	float bmpam = (Instancing) ? InstancedParams[ii].BumpAmount*FBumpAmount : FBumpAmount;
	float depth = bmpam;
	float mdepth = BumpTex.Sample(Sampler, uvb).r + bumpOffset;
	if(isTriPlanar) mdepth = TriPlanarSample(BumpTex, Sampler, In.TexCd.xyz, In.NormW, tT, TriPlanarPow).r;
	
	if(depth!=0) posWb += In.NormW * mdepth * -1*depth;
	Out.normalW = float4(normWb,1);
	
	float alphat = 1;
	float alphatt = DiffTex.Sample( Sampler, uvb).a * FDiffColor.a;
	if(isTriPlanar) alphatt = TriPlanarSample(DiffTex, Sampler, In.TexCd.xyz, In.NormW, tT, TriPlanarPow).a * FDiffColor.a;
	alphat = alphatt;
	if(alphat < (1-alphatest)) discard;
    
    float3 diffcol = DiffTex.Sample( Sampler, uvb).rgb;
	if(isTriPlanar) diffcol = TriPlanarSample(DiffTex, Sampler, In.TexCd.xyz, In.NormW, tT, TriPlanarPow).rgb;
	if(Instancing)
	{
    	diffcol *= FDiffColor.rgb * FDiffAmount * InstancedParams[ii].DiffAmount * InstancedParams[ii].DiffCol.rgb;
	}
	else
	{
		diffcol *= FDiffColor.rgb * FDiffAmount;
	}
    //float3 diffcol = combinedDist*10;
	Out.color.rgb = diffcol;
	Out.color.a = 1;
	
	float4 posout = mul(float4(posWb,1),tVP);
	Out.position = posout.z/posout.w;
	
	Out.velocity.rgb = In.vel.xyz-.5;
	Out.velocity.rgb *= min(3,2/mul(float4(posWb,1),tV).z);
	Out.velocity.rgb +=.5;
	Out.velocity.a = alphat + utilalpha;
	
	if(Instancing)
	{
		Out.matprop.b = InstancedParams[ii].MatID;
		Out.matprop.a = InstancedParams[ii].ObjID0;
	}
	else
	{
		Out.matprop.b = MatID;
		Out.matprop.a = ObjID;
	}
	Out.matprop.rg = uvb;
	
    return Out;
}

PSOut PS_Inst(vs2gsi In)
{
	float ii = In.ii;
	float3 posWb = In.PosW.xyz;

	PSOut Out = (PSOut)0;
	float3 normWb = In.NormW;
	float2 uvb = float2(0,0);
	
	float4x4 tT = (InstanceFromGeomFX|| Instancing) ? mul(InstancedParams[ii].tTex,tTex) : tTex;
	uvb = In.TexCd.xy;
	
	float bmpam = (InstanceFromGeomFX|| Instancing) ? InstancedParams[ii].BumpAmount*FBumpAmount : FBumpAmount;
	float depth = bmpam;
	float mdepth = BumpTex.Sample(Sampler, uvb).r + bumpOffset;
	if(isTriPlanar) mdepth = TriPlanarSample(BumpTex, Sampler, In.TexCd.xyz, In.NormW, tT, TriPlanarPow).r;
	
	if(depth!=0) posWb += In.NormW * mdepth * -1*depth;
	Out.normalW = float4(normWb,1);
	
	float alphat = 1;
	float alphatt = DiffTex.Sample( Sampler, uvb).a * FDiffColor.a;
	alphat = alphatt;
	if(alphatest!=0)
	{
		alphat = lerp(alphatt, (alphatt>=alphatest), min(alphatest*10,1));
		if(alphat < (1-alphatest)) discard;
	}
	
    float3 diffcol = DiffTex.Sample( Sampler, uvb).rgb;
	if(isTriPlanar) diffcol = TriPlanarSample(DiffTex, Sampler, In.TexCd.xyz, In.NormW, tT, TriPlanarPow).rgb;
	if(InstanceFromGeomFX|| Instancing)
	{
    	diffcol *= FDiffColor.rgb * FDiffAmount * InstancedParams[ii].DiffAmount * InstancedParams[ii].DiffCol.rgb;
	}
	else
	{
		diffcol *= FDiffColor.rgb * FDiffAmount;
	}
	Out.color.rgb = diffcol;
	Out.color.a = alphat;
	
	float4 posout = mul(float4(posWb,1),tVP);
	Out.position = posout.z/posout.w;
	
	Out.velocity.rgb = In.vel.xyz-.5;
	Out.velocity.rgb *= min(3,2/mul(float4(posWb,1),tV).z);
	Out.velocity.rgb +=.5;
	Out.velocity.a = alphat + utilalpha;
	
	if(InstanceFromGeomFX|| Instancing)
	{
		Out.matprop.b = InstancedParams[ii].MatID;
		Out.matprop.a = InstancedParams[ii].ObjID0;
	}
	else
	{
		Out.matprop.b = MatID;
		Out.matprop.a = ObjID;
	}
	Out.matprop.rg = uvb;
	
    return Out;
}

technique10 DeferredBase
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_Tex() ) );
	}
}
/*
technique10 DeferredBaseInstanced
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}*/

technique10 DeferredBaseGeomVel
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VSgv() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_Inst() ) );
	}
}