Shader "Custom/light_BetterBlinnPhongWithTex"
 {
	Properties
	{
		_MaterialColor("MaterialColor",Color) = (1,1,1,1)
		_SpecularStrength("Specular",Range(0.0,5.0)) = 1.0
		_Gloss("Gloss",Range(1.0,255)) = 20
		_MainTex("Main Texture",2D) = "white"{}
		_Cutoff("alpha cutoff",Range(0,1)) = 0.5
	}
SubShader{
	Pass{
	Tags{ "LightingType" = "ForwardBase" }
	LOD 200
	CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag
	fixed4 _MaterialColor;
float _SpecularStrength;
float _Gloss;
sampler2D _MainTex;
float4 _MainTex_ST;
fixed _Cutoff;
struct appdata {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 uv : TEXCOORD0;
};

struct v2f {
	float4 pos : SV_POSITION;
	float3 worldNormal : NORMAL;
	float3 worldPos : TEXCOORD2;
	float3 viewDir : TEXCOORD0;
	float2 uv : TECOORD1;
};

v2f vert(appdata v) {
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex); 
	o.worldNormal = UnityObjectToWorldNormal(v.normal); 
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
	o.viewDir = _WorldSpaceCameraPos - o.worldPos;
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	return o;
}
fixed4 frag(v2f i) : SV_Target
{
	fixed4 tex = tex2D(_MainTex, i.uv);
	clip(tex.a - _Cutoff);

	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	//fixed3 ambient = (1.,1.,1.);
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
	fixed lambert =max(0, dot(worldNormal, worldLightDir));
	fixed3 diffuse = lambert * _LightColor0.xyz;

	fixed3 viewDir = normalize(i.viewDir);
	fixed3 halfDir = normalize(worldLightDir + viewDir); 
fixed3 specular = _LightColor0.rgb *_SpecularStrength * pow(max(0.0, dot(halfDir, worldNormal)), _Gloss);


//纹理中rgb为正常颜色，a为一个高光的mask图，非高光部分a值为0，高光部分根据a的值控制高光强度
fixed3 color = (ambient * _MaterialColor.rgb + diffuse * _MaterialColor.rgb + specular * _MaterialColor.rgb * tex.a) * tex.rgb;

return fixed4(color, 1.0);

}
ENDCG
}
}
FallBack "Diffuse"
}
