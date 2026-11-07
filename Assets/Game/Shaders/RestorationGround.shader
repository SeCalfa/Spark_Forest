Shader "SparkForest/RestorationGround"
{
    Properties
    {
        _BaseMap ("Ground Texture", 2D) = "white" {}
        _DeadTint ("Dead Color", Color) = (1,1,1,1)
        _AliveTint ("Alive Color", Color) = (0.88,1.15,0.85,1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        Pass
        {
            Name "RestorationGround"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _DeadTint;
                half4 _AliveTint;
            CBUFFER_END

            // Set by SpiritRestorationGlobals.cs; intentionally not material properties.
            float4 _SF_SpiritPosition;
            float _SF_Radius;
            float _SF_Feather;
            float _SF_Strength;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs pos = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = pos.positionCS;
                output.positionWS = pos.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half3 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb;
                float d = distance(input.positionWS.xz, _SF_SpiritPosition.xz);
                float outerRadius = max(_SF_Radius, 0.001);
                float innerRadius = max(0.0, outerRadius - max(_SF_Feather, 0.001));
                float influence = (1.0 - smoothstep(innerRadius, outerRadius, d))
                                  * saturate(_SF_Strength);
                half3 tint = lerp(_DeadTint.rgb, _AliveTint.rgb, influence);
                return half4(tex * tint, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
