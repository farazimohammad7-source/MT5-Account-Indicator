#property strict
#property description "Account Info Panel - Draggable"

input string sFontName = "Tahoma";
input int    iFontSize = 12;
input int    iPanelWidth = 220;
input int    iPanelHeight = 110;

input color clrPanelBack = C'18,18,18';
input color clrPanelBorder = C'80,120,255';
input color clrTitle = clrWhite;
input color clrBalance = clrDodgerBlue;
input color clrEquity = clrSilver;
input color clrProfit = clrLimeGreen;
input color clrLoss = clrTomato;

string g_panel  = "AccountPanel";
string g_title  = "AccountTitle";
string g_balance = "AccountBalance";
string g_equity = "AccountEquity";
string g_profit = "AccountProfit";

bool bDragging = false;
int iOffsetX = 0;
int iOffsetY = 0;

int OnInit()
{
   CreatePanel(30, 30);
   CreateText(g_title,   "ACCOUNT INFO", clrTitle,   10, 8,  12, true);
   CreateText(g_balance, "Balance: --", clrBalance, 10, 32, iFontSize, false);
   CreateText(g_equity,  "Equity: --",  clrEquity,  10, 55, iFontSize, false);
   CreateText(g_profit,  "P/L: --",     clrProfit,  10, 78, iFontSize, false);

   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteObject(g_panel);
   DeleteObject(g_title);
   DeleteObject(g_balance);
   DeleteObject(g_equity);
   DeleteObject(g_profit);
}

void OnTimer()
{
   UpdateAccountInfo();
}

void OnTick()
{
   UpdateAccountInfo();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Mouse down on panel
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == g_panel)
      {
         bDragging = true;
         int mouseX = (int)lparam;
         int mouseY = (int)dparam;
         int panelX = (int)ObjectGetInteger(0, g_panel, OBJPROP_XDISTANCE);
         int panelY = (int)ObjectGetInteger(0, g_panel, OBJPROP_YDISTANCE);
         
         iOffsetX = mouseX - panelX;
         iOffsetY = mouseY - panelY;
      }
   }

   // Mouse move while dragging
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
      if(sparam == g_panel && bDragging)
      {
         int mouseX = (int)lparam;
         int mouseY = (int)dparam;

         int newX = mouseX - iOffsetX;
         int newY = mouseY - iOffsetY;

         // Keep panel within chart bounds
         if(newX < 0) newX = 0;
         if(newY < 0) newY = 0;

         ObjectSetInteger(0, g_panel, OBJPROP_XDISTANCE, newX);
         ObjectSetInteger(0, g_panel, OBJPROP_YDISTANCE, newY);

         // Update text positions with panel
         ObjectSetInteger(0, g_title,   OBJPROP_XDISTANCE, newX + 10);
         ObjectSetInteger(0, g_title,   OBJPROP_YDISTANCE, newY + 8);

         ObjectSetInteger(0, g_balance, OBJPROP_XDISTANCE, newX + 10);
         ObjectSetInteger(0, g_balance, OBJPROP_YDISTANCE, newY + 32);

         ObjectSetInteger(0, g_equity,  OBJPROP_XDISTANCE, newX + 10);
         ObjectSetInteger(0, g_equity,  OBJPROP_YDISTANCE, newY + 55);

         ObjectSetInteger(0, g_profit,  OBJPROP_XDISTANCE, newX + 10);
         ObjectSetInteger(0, g_profit,  OBJPROP_YDISTANCE, newY + 78);

         ChartRedraw();
      }
   }

   // Mouse release
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      bDragging = false;
   }
}

void UpdateAccountInfo()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit  = AccountInfoDouble(ACCOUNT_PROFIT);
   string currency = AccountInfoString(ACCOUNT_CURRENCY);

   string balanceText = "Balance: " + DoubleToString(balance, 2) + " " + currency;
   string equityText  = "Equity:  " + DoubleToString(equity, 2) + " " + currency;
   string profitText  = "P/L:     " + DoubleToString(profit, 2) + " " + currency;

   color profitColor = (profit >= 0) ? clrProfit : clrLoss;

   ObjectSetString(0, g_balance, OBJPROP_TEXT, balanceText);
   ObjectSetInteger(0, g_balance, OBJPROP_COLOR, (long)clrBalance);

   ObjectSetString(0, g_equity, OBJPROP_TEXT, equityText);
   ObjectSetInteger(0, g_equity, OBJPROP_COLOR, (long)clrEquity);

   ObjectSetString(0, g_profit, OBJPROP_TEXT, profitText);
   ObjectSetInteger(0, g_profit, OBJPROP_COLOR, (long)profitColor);
}

void CreatePanel(int x, int y)
{
   if(ObjectFind(0, g_panel) == -1)
   {
      if(!ObjectCreate(0, g_panel, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      {
         Print("Panel creation failed: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, g_panel, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_panel, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_panel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_panel, OBJPROP_XSIZE, iPanelWidth);
   ObjectSetInteger(0, g_panel, OBJPROP_YSIZE, iPanelHeight);
   ObjectSetInteger(0, g_panel, OBJPROP_BGCOLOR, (long)clrPanelBack);
   ObjectSetInteger(0, g_panel, OBJPROP_COLOR, (long)clrPanelBorder);
   ObjectSetInteger(0, g_panel, OBJPROP_BORDER_COLOR, (long)clrPanelBorder);
   ObjectSetInteger(0, g_panel, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, g_panel, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, g_panel, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, g_panel, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panel, OBJPROP_HIDDEN, false);
}

void CreateText(string name, string text, color txtColor, int x, int y, int fontSize, bool bold)
{
   if(ObjectFind(0, name) == -1)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         Print("Text creation failed: ", name);
         return;
      }
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + 30);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y + 30);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (long)txtColor);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, sFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   if(bold)
      ObjectSetString(0, name, OBJPROP_FONT, "Tahoma Bold");
}

void DeleteObject(string name)
{
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
}
