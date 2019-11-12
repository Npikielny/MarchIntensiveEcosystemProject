if (_geometry.position.y > 0.2) {
    _geometry.position.x += sin(u_time-_geometry.position.x/2+_geometry.position.z/2)/4*_geometry.position.y/4;
    _geometry.position.y += sin(u_time+_geometry.position.x/2+_geometry.position.z/2)/4*_geometry.position.y/4;
    _geometry.position.z += sin(u_time+_geometry.position.x/2-_geometry.position.z/2)/4*_geometry.position.y/4;
}
