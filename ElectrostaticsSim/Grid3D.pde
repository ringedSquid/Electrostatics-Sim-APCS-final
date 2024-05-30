import org.hipparchus.linear.*;
import java.util.*;

public class Grid3D {
  /* res x res x res grid */
  private int res;
  /* actual size length of the grid in units */
  private float size;
  /* z, y, x */
  private Cell initGrid[][][];
  private Cell solvedGrid[][][];
  
  /* colleciton of objects */
  private ArrayList<CellObj> objList;
  
  /* initRes > initSize, initSize must be divisible by initRes */
  public Grid3D(int initRes, float initSize) {
    res = initRes;
    size = initSize;
    
    /* initialize grid */
    /* edges not included */
    initGrid = new Cell[res+2][res+2][res+2];
    
    /* initialize grid cells */
    for (int i=0; i<res+2; i++) {
      for (int j=0; j<res+2; j++) {
        for (int k=0; k<res+2; k++) {
          /* Boundary conditions */
          if ((i==0)||(j==0)||(k==0)||(i==res+1)||(j==res+1)||(k==res+1)) {
            initGrid[i][j][k] = new Cell(
                                    new PVector(i*size, j*size, k*size), 
                                    size,
                                    color(0),
                                    Double.valueOf(0),
                                    Double.valueOf(0),
                                    Cell.pVacuum,
                                    new PVector(0, 0, 0)
                                    );
          }
          else {  
            initGrid[i][j][k] = new Cell(
                                     new PVector(i*size, j*size, k*size), 
                                     size
                                     );
          }
        }
      }
    }
  }
  
  
  
  /* solve Poisson's equations using FDM for p, V, and E */
  public void solveSystem() {
    int realRes = (res+2);
    int cubeRes = (int)pow((res+2), 3);
    solvedGrid = new Cell[realRes][realRes][realRes];
    
    /* potential is the main unknown quantity */
    OpenMapRealMatrix coeffMatrix = new OpenMapRealMatrix(cubeRes, cubeRes);
    RealVector yVector = new ArrayRealVector(cubeRes);
    RealVector solnVector;
    DecompositionSolver solver;
   
   /* tracks if charge and potential are swapped */
    boolean[] swapTracker = new boolean[(int)pow((res+2), 3)];

    for (int i=0; i<realRes; i++) {
      for (int j=0; j<realRes; j++) {
        for (int k=0; k<realRes; k++) {
          int index = getIndex(i, j, k);
          solvedGrid[i][j][k] = initGrid[i][j][k];
          
          /* potential != null */
          //System.out.println(initGrid[i][j][k].getCharge());
          if (initGrid[i][j][k].getCharge() == null) {
            swapTracker[index] = true;
            yVector.setEntry(index, (-1)*initGrid[i][j][k].getPotential().doubleValue());
          }
          else {
            swapTracker[index] = false;
            yVector.setEntry(index, initGrid[i][j][k].getCharge().doubleValue());
          } 
        }
      }
    }
    
    /* init CoeffMatrix */
    for (int i=0; i<realRes; i++) {
      for (int j=0; j<realRes; j++) {
        for (int k=0; k<realRes; k++) {
          int index = getIndex(i, j, k);
          if (swapTracker[index] == true) {
            /* V */
            coeffMatrix.setEntry(index, getIndex(i, j, k), 1/(6.0));
            /* V(i+d) */
            if (i < res+1) {
              coeffMatrix.setEntry(index, getIndex(i+1, j, k), solvedGrid[i+1][j][k].getPerm()/6);
            }
            /* V(i-d) */
            if (i > 0) {
              coeffMatrix.setEntry(index, getIndex(i-1, j, k), solvedGrid[i-1][j][k].getPerm()/6);
            }
            /* V(j+d) */
            if (j < res+1) {
              coeffMatrix.setEntry(index, getIndex(i, j+1, k), solvedGrid[i][j+1][k].getPerm()/6);
            }
            /* V(j-d) */
            if (j > 0) {
              coeffMatrix.setEntry(index, getIndex(i, j-1, k), solvedGrid[i][j-1][k].getPerm()/6);
            }
            /* V(k+d) */
            if (k < res+1) {
              coeffMatrix.setEntry(index, getIndex(i, j, k+1), solvedGrid[i][j][k+1].getPerm()/6);
            }
            /* V(k-d) */
            if (k > 0) {
              coeffMatrix.setEntry(index, getIndex(i, j, k-1), solvedGrid[i][j][k-1].getPerm()/6);
            }
          }
          else { 
            /* V */
            coeffMatrix.setEntry(index, getIndex(i, j, k), 6*solvedGrid[i][j][k].getPerm()/pow(solvedGrid[i][j][k].getSize(), 2));
            /* V(i+d) */
            if (i < res+1) {
              coeffMatrix.setEntry(index, getIndex(i+1, j, k), -solvedGrid[i+1][j][k].getPerm()/pow(solvedGrid[i+1][j][k].getSize(), 2));
            }
            /* V(i-d) */
            if (i > 0) {
              coeffMatrix.setEntry(index, getIndex(i-1, j, k), -solvedGrid[i-1][j][k].getPerm()/pow(solvedGrid[i-1][j][k].getSize(), 2));
            }
            /* V(j+d) */
            if (j < res+1) {
              coeffMatrix.setEntry(index, getIndex(i, j+1, k), -solvedGrid[i][j+1][k].getPerm()/pow(solvedGrid[i][j+1][k].getSize(), 2));
            }
            /* V(j-d) */
            if (j > 0) {
              coeffMatrix.setEntry(index, getIndex(i, j-1, k), -solvedGrid[i][j-1][k].getPerm()/pow(solvedGrid[i][j-1][k].getSize(), 2));
            }
            /* V(k+d) */
            if (k < res+1) {
              coeffMatrix.setEntry(index, getIndex(i, j, k+1), -solvedGrid[i][j][k+1].getPerm()/pow(solvedGrid[i][j][k+1].getSize(), 2));
            }
            /* V(k-d) */
            if (k > 0) {
              coeffMatrix.setEntry(index, getIndex(i, j, k-1), -solvedGrid[i][j][k-1].getPerm()/pow(solvedGrid[i][j][k-1].getSize(), 2));
            }
          }
        }
      }
    }
  
    
   /* solve! */
   //RealMatrixFormat poob = new RealMatrixFormat("", "", "", "", "\n", " ");
   solver = new LUDecomposition(coeffMatrix).getSolver();
   /*
   System.out.println(yVector.getDimension());
   System.out.println(coeffMatrix.getRowDimension() + ", " + coeffMatrix.getColumnDimension());
   System.out.println(Arrays.toString(swapTracker));
   System.out.println(poob.format(coeffMatrix));
   */
   solnVector = solver.solve(yVector);
   
   
   /* update solved grid */
   for (int i=0; i<realRes; i++) {
      for (int j=0; j<realRes; j++) {
        for (int k=0; k<realRes; k++) {
          if (!((i==0)||(j==0)||(k==0)||(i==res+1)||(j==res+1)||(k==res+1))) {
            int index = getIndex(i, j, k);
            if (swapTracker[index] == true) {
              solvedGrid[i][j][k].setCharge(Double.valueOf(solnVector.getEntry(index)));
            }
            else {
              solvedGrid[i][j][k].setPotential(Double.valueOf(solnVector.getEntry(index)));
            }
          }
        }
      }
    }
    
    
    //System.out.println(realRes);
    float[][] charges = new float[realRes][realRes];
    
    for (int k=0; k<realRes; k++) {
      
    for (int i=0; i<realRes; i++) {
      for (int y=0; y<realRes; y++) {
        charges[i][y] = (float)solvedGrid[i][k][y].getPotential().doubleValue();
      }
    }
    
    for (int i=0; i<realRes; i++) {
      for (int y=0; y<realRes; y++) {
        System.out.print(String.format("%03.3f ", charges[i][y]));
      }
      System.out.println();
    }
    System.out.println("\n" + k);
    }
  }
  

  
  public int getIndex(int i, int j, int k) {
    return i + (res+2)*j + (res+2)*(res+2)*k;
  }
  
  /* changes size of grid */ 
  public void changeSize() {
  }
  
  /*
  public void setCell(int i, int j, int k, Cell newCell) {
    grid[i][j][k] = newCell;
  }
  */
  
  public Cell getCell(int i, int j, int k) { 
    return solvedGrid[i][j][k];
  }
  
  public Cell getInitCell(int i, int j, int k) { 
    return initGrid[i][j][k];
  }
  
  public int getRes() {
    return res;
  }
  
  
}
