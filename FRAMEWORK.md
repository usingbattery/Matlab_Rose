# framework:
## class flower

    render(){
      attribute=get_attribute();
      component=new component(attribute);
      component.render();
    }

## class rose<flower

    get_attribute(){};

## class component
//class petal and branch

    render(){
      points=get_points();
      surf(points);
    }
