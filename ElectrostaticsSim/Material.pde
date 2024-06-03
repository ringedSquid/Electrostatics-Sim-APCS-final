public class Material {
  private float perm;
  private Double charge;
  private Double potential;
  private char type;
  private String name;
  
  public Material(
    String initName, char initType, 
    float initPerm, Double initCharge, Double initPotential
    )
  {
    name = initName;
    type = initType;
    perm = initPerm;
    charge = initCharge;
    potential = initPotential;
  }
  
  public float getPerm() {
    return perm;
  }
  
  public char getType() {
    return type;
  }
  
  public Double getCharge() {
    return charge;
  }
  
  public Double getPotential() {
    return potential;
  }
  
  public String getName() {
    return name;
  }
}
