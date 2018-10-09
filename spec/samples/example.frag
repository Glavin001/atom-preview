// Fragment shader example (phong).
// Based on example from https://www.opengl.org/sdk/docs/tutorials/ClockworkCoders/lighting.php
//
// Uncomment any combination of following defines to see how it changes
// preprocessor output in preview pane.

//#define DIFFUSE
//#define AMBIENT
//#define SPECULAR

#if defined DIFFUSE || defined SPECULAR
varying vec3 N;
varying vec3 v;
#endif

void main (void)
{
#if defined DIFFUSE || defined SPECULAR
	vec3 L = normalize(gl_LightSource[0].position.xyz - v);
#endif

#ifdef AMBIENT
	vec4 ambient = gl_FrontLightProduct[0].ambient;
#endif

#ifdef DIFFUSE
	vec4 diffuse = gl_FrontLightProduct[0].diffuse * max(dot(N,L), 0.0);
	diffuse = clamp(diffuse, 0.0, 1.0);
#endif

#ifdef SPECULAR
	vec3 E = normalize(-v); // we are in Eye Coordinates, so EyePos is (0,0,0)
	vec3 R = normalize(-reflect(L,N));

	vec4 specular = gl_FrontLightProduct[0].specular
		* pow(max(dot(R,E),0.0),0.3*gl_FrontMaterial.shininess);
	specular = clamp(specular, 0.0, 1.0);
#endif
	gl_FragColor = gl_FrontLightModelProduct.sceneColor
#ifdef AMBIENT
	+ ambient
#endif
#ifdef DIFFUSE
	+ diffuse
#endif
#ifdef SPECULAR
	+ specular
#endif
  ;
}
