uniform float offset;
uniform float travelRadius;
uniform float angle;
uniform float moveRate;

float scaleCoef = u_time/float(2)+offset/moveRate * float(2) * 3.1415926;

_geometry.position.x = _geometry.position.x * abs(sin(scaleCoef));
_geometry.position.z = _geometry.position.z * abs(sin(scaleCoef));


_geometry.position.y = _geometry.position.y * abs(sin(scaleCoef));

float roundedAngle = angle + floor(scaleCoef / 3.1415926) * moveRate;

vec3 initial_position = vec3(travelRadius*cos(angle),0,travelRadius*sin(angle));
vec3 rotatedPosition = vec3(travelRadius*cos(roundedAngle),0,travelRadius*sin(roundedAngle));

_geometry.position.x = _geometry.position.x - initial_position.x + rotatedPosition.x;
_geometry.position.y = _geometry.position.y - initial_position.y + rotatedPosition.y;
_geometry.position.z = _geometry.position.z - initial_position.z + rotatedPosition.z;
