Shader "Unlit/BillboardExample"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Tint ("Tint", Color) = (1, 1, 1, 1)
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
	
		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		half4 _Tint;

		v2f vertBillboard(appdata v)
		{
			v2f o;
		
			float scaleX = length(unity_ObjectToWorld._m00_m10_m20);
			float scaleY = length(unity_ObjectToWorld._m01_m11_m21);
		
			//===get object origin position in view space===
			//#1
			//float4 vPosition = UNITY_MATRIX_MV._m03_m13_m23_m33; //float4( UnityObjectToViewPos( float4(0,0,0,1) ), 1.0 )
			//#2
			float3 vPosition = UnityObjectToViewPos(float4(0, 0, 0, 1));
			//==============================================

			o.vertex = UnityViewToClipPos(vPosition + float3(v.vertex.x * scaleX, v.vertex.y * scaleY, 0.0));

			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			return o;
		}


		v2f vertBillboard2(appdata v)
		{
			v2f o ;
		
			float scaleX = length(unity_ObjectToWorld._m00_m10_m20);
			float scaleY = length(unity_ObjectToWorld._m01_m11_m21);

			//===remove rotation from model*view matrix and keep x,y scale===
			float4x4 mvMatrix = UNITY_MATRIX_MV;
			mvMatrix._m00_m01_m02 = float3(scaleX, 0, 0);
			mvMatrix._m10_m11_m12 = float3(0, scaleY, 0);
			mvMatrix._m20_m21_m22 = float3(0, 0, 0);


			o.vertex = mul(UNITY_MATRIX_P, mul(mvMatrix, v.vertex));

			o.uv = TRANSFORM_TEX(v.uv, _MainTex);



			return o;
		}


		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex, i.uv) * _Tint;
		
			return col;
		}
	ENDCG

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off

			CGPROGRAM

			#pragma vertex vertBillboard
			#pragma fragment frag

			ENDCG

		}
	}
}
