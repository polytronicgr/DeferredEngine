﻿
//SSS attempt, TheKosmonaut 2016

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  VARIABLES
////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../Common/helper.fx"

float4x4  World;
float4x4  WorldViewProj;
float3x3  WorldViewIT;

//float FarClip;

Texture2D DepthMap;
Texture2D AlbedoMap;
Texture2D NormalMap;

SamplerState texSampler
{
    Texture = (DepthMap);
    AddressU = CLAMP;
    AddressV = CLAMP;
    MagFilter = POINT;
    MinFilter = POINT;
    Mipfilter = POINT;
};
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  STRUCTS
////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float3 Normal   : NORMAL0;
};

struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float3 WorldPosition : TEXCOORD0;
	float3 Normal : NORMAL;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//  VERTEX SHADER
	////////////////////////////////////////////////////////////////////////////////////////////////////////////


VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;
	output.Position = mul(input.Position, WorldViewProj);
	output.WorldPosition = mul(input.Position, World).xyz;
	output.Normal = mul(input.Normal, WorldViewIT);

    return output;

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//  PIXEL SHADER
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  HELPER FUNCTIONS
		////////////////////////////////////////////////////////////////////////////////////////////////////////////

		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  Main function
		////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool isSSS(int3 texCoord)
{
	float a = AlbedoMap.Load(texCoord).a;
	a = decodeMattype(a);

	return abs(a - 4) < 0.1f;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR
{
	//float2 texCoord = float2(input.TexCoord);

	//int3 texCoord = int3(input.Position.xy, 0);

	//float4 normalData = NormalMap.Load(texCoord);
	////tranform normal back into [-1,1] range
	//float3 normal = decode(normalData.xyz);

	//if (!isSSS(texCoord)) discard;

	//Curvature

	float3 pos_ddx = ddx(input.WorldPosition);
	float3 pos_ddy = ddy(input.WorldPosition);

	float3 nor_ddx = ddx(input.Normal);
	float3 nor_ddy = ddy(input.Normal);

	float3 diff = nor_ddx / pos_ddx + nor_ddy / pos_ddy;
	diff *= 0.5f;
	/*diff = abs(diff);*/

	return float4(diff, 1);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//  TECHNIQUES
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique Default
{
	pass Pass1
	{
		VertexShader = compile vs_5_0 VertexShaderFunction();
		PixelShader = compile ps_5_0 PixelShaderFunction();
	}
}

