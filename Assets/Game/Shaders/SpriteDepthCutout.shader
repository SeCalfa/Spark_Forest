Shader "SparkForest/SpriteDepthCutout"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Tint ("Art Tint", Color) = (1,1,1,1)
        _Brightness ("Brightness", Range(0,2)) = 1
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.25
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "TransparentCutout"
            "Queue" = "AlphaTest"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        ZWrite On
        ZTest LEqual

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        CBUFFER_START(UnityPerMaterial)
            half4 _Tint;
            half _Brightness;
            half _Cutoff;
        CBUFFER_END

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            half4 color : COLOR;
        };

        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            half4 color : COLOR;
        };

        Varyings Vert(Attributes input)
        {
            Varyings output;
            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv = input.uv;
            output.color = input.color;
            return output;
        }

        half4 GetSpriteColor(Varyings input)
        {
            half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
            return tex * input.color * _Tint;
        }

        half4 FragForward(Varyings input) : SV_Target
        {
            half4 color = GetSpriteColor(input);
            clip(color.a - _Cutoff);
            return half4(color.rgb * _Brightness, 1.0h);
        }

        half4 FragDepth(Varyings input) : SV_Target
        {
            half4 color = GetSpriteColor(input);
            clip(color.a - _Cutoff);
            return half4(0,0,0,0);
        }
        ENDHLSL

        Pass
        {
            Name "SpriteForward"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragForward
            ENDHLSL
        }

        Pass
        {
            Name "SpriteDepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment FragDepth
            ENDHLSL
        }
    }
    FallBack Off
}
