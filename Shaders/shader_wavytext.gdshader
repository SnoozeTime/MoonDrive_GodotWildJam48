shader_type canvas_item;

uniform float height = 20.0;
uniform float speed = 1.;
uniform float frequency = 5.0;
void vertex() {
	VERTEX.y += sin(frequency*(UV.x)+(speed*TIME))*height;
}
