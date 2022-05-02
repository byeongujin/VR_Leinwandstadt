Shader "Flip Normals" {
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        // Render the object inside-out.
        Cull Front

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {               
                float4 vertex : SV_POSITION;
                // Pass a view direction instead of a UV coordinate.
                float3 direction : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Compute worldspace direction from the camera to this vertex.
                o.direction = mul(unity_ObjectToWorld, v.vertex).xyz 
                               - _WorldSpaceCameraPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Convert the direction to the fragment into latitude & longitude.
                float3 pos = normalize(i.direction);
                float2 uv;       
                uv.x = atan2(pos.z, pos.x)* 0.5f;
                uv.y = asin(pos.y);

                // Scale and shift into the 0...1 texture coordinate range.
                uv = uv / 3.141592653589f + 0.5f;

                // Used directly, we'll get a texture filtering seam
                // where the longitude wraps around from 1 to 0.
                // This fixes that (you can skip this if your videos don't mipmap)
                float2 dx = ddx(uv);
                float2 dy = ddy(uv);
                float2 du = float2(dx.x, dy.x);
                du -= (abs(du) > 0.5f) * sign(du);
                dx.x = du.x;
                dy.x = du.y;

                // In case you want to rotate your view using the texture x-offset.
                uv.x += _MainTex_ST.z;     

                // Sample the texture with our calculated UV & seam fixup.
                fixed4 col = tex2Dgrad(_MainTex, uv, dx, dy);

                return col;
            }
            ENDCG
        }
    }
}