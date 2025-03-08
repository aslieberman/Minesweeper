import de.bezier.guido.*;

public static final int NUM_ROWS = 16;
public static final int NUM_COLS = 16;
public static final int TOTAL_MINES = 40;

private MSButton[][] buttons;
private ArrayList<MSButton> mines;

void setup() {
  size(400, 400);
  textAlign(CENTER, CENTER);
  Interactive.make(this);
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  mines = new ArrayList<MSButton>();
  int buttonWidth = width / NUM_COLS;
  int buttonHeight = height / NUM_ROWS;
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      buttons[row][col] = new MSButton(row, col, buttonWidth, buttonHeight);
    }
  }
  setMines();
}

void draw() {
  background(0);
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      buttons[row][col].draw();
    }
  }
  if (isWon()) {
    win();
  }
}

public void setMines() {
  int placedMines = 0;
  while (placedMines < TOTAL_MINES) {
    int randRow = (int)(Math.random() * NUM_ROWS);
    int randCol = (int)(Math.random() * NUM_COLS);
    MSButton candidate = buttons[randRow][randCol];
    if (!mines.contains(candidate)) {
      mines.add(candidate);
      candidate.hasMine = true;
      placedMines++;
    }
  }
}

public boolean isWon() {
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      MSButton b = buttons[row][col];
      if (!b.hasMine && !b.clicked) return false;
    }
  }
  return true;
}

public void loss() {
  for (MSButton m : mines) {
    m.clicked = true;
    m.setLabel("M");
  }
  noLoop();
}

public void win() {
  noLoop();
}

public boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (isValid(r, c) && !(r == row && c == col)) {
        if (buttons[r][c].hasMine) numMines++;
      }
    }
  }
  return numMines;
}

public class MSButton {
  private int myRow, myCol;
  private int x, y, w, h;
  public boolean clicked, flagged;
  private String myLabel;
  public boolean hasMine;
  
  public MSButton(int row, int col, int w, int h) {
    myRow = row;
    myCol = col;
    this.w = w;
    this.h = h;
    x = myCol * w;
    y = myRow * h;
    myLabel = "";
    clicked = false;
    flagged = false;
    hasMine = false;
    Interactive.add(this);
  }
  
  public boolean isInside(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }
  
  public void mousePressed() {
    if (clicked) return;
    if (mouseButton == RIGHT) {
      flagged = !flagged;
      if (!flagged) clicked = false;
      return;
    }
    if (flagged) return;
    clicked = true;
    if (hasMine) {
      loss();
      return;
    }
    int count = countMines(myRow, myCol);
    if (count > 0) {
      setLabel(count);
    } else {
      setLabel("");
      for (int r = myRow - 1; r <= myRow + 1; r++) {
        for (int c = myCol - 1; c <= myCol + 1; c++) {
          if (isValid(r, c) && !(r == myRow && c == myCol)) {
            MSButton neighbor = buttons[r][c];
            if (!neighbor.clicked && !neighbor.flagged) {
              neighbor.mousePressed();
            }
          }
        }
      }
    }
  }
  
  public void draw() {
    if (flagged)
      fill(50);
    else if (clicked && hasMine)
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else
      fill(100);
    rect(x, y, w, h);
    fill(0);
    text(myLabel, x + w/2, y + h/2);
  }
  
  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }
  
  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }
  
  public boolean isFlagged() {
    return flagged;
  }
}
