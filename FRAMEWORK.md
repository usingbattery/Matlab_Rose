# framework:
## class flower{

  render(){
  
    attribute=get_attribute();
    
    component=new component(attribute);
    
    component.render();
    
  }
  
}

## class rose extends flower{

  get_attribute();
  
}

## class component{

  //petal and branch
  
  render(){
  
    points=get_points();
    
    surf(points);
    
  }
  
}
