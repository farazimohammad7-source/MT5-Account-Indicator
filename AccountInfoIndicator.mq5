#property strict

input string sFontName = "Tahoma";
input int    iFontSize = 12;

input int    iPanelX = 30;
input int    iPanelY = 30;
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

int OnInit()
{
   CreatePanel();
   CreateText(g_title,  "ACCOUNT INFO", clrTitle, 10, 8, 12, true);
   CreateText(g_balance, "Balance: --", clrBalance, 10, 32, iFontSize, false);
   CreateText(g_equity, "Equity: --", clrEquity, 10, 55, iFontSize, false);
   CreateText(g_profit, "P/L: --", clrProfit, 10, 78, iFontSize, false);

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
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
      if(sparam == g_panel)
      {
         long x = (long)ObjectGetInteger(0, g_panel, OBJPROP_XDISTANCE);
         long y = (long)ObjectGetInteger(0, g_panel, OBJPROP_YDISTANCE);

         ObjectSetInteger(0, g_title,  OBJPROP_XDISTANCE, x + 10);
         ObjectSetInteger(0, g_title,  OBJPROP_YDISTANCE, y + 8);

         ObjectSetInteger(0, g_balance, OBJPROP_XDISTANCE, x + 10);
         ObjectSetInteger(0, g_balance, OBJPROP_YDISTANCE, y + 32);

         ObjectSetInteger(0, g_equity,  OBJPROP_XDISTANCE, x + 10);
         ObjectSetInteger(0, g_equity,  OBJPROP_YDISTANCE, y + 55);

         ObjectSetInteger(0, g_profit,  OBJPROP_XDISTANCE, x + 10);
         ObjectSetInteger(0, g_profit,  OBJPROP_YDISTANCE, y + 78);
      }
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

void CreatePanel()
{
   if(ObjectFind(0, g_panel) == -1)
   {
      if(!ObjectCreate(0, g_panel, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      {
         Print("Panel creation failed: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, g_panel, OBJPROP_XDISTANCE, iPanelX);
   ObjectSetInteger(0, g_panel, OBJPROP_YDISTANCE, iPanelY);
   ObjectSetInteger(0, g_panel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_panel, OBJPROP_XSIZE, iPanelWidth);
   ObjectSetInteger(0, g_panel, OBJPROP_YSIZE, iPanelHeight);

   ObjectSetInteger(0, g_panel, OBJPROP_BGCOLOR, (long)clrPanelBack);
   ObjectSetInteger(0, g_panel, OBJPROP_COLOR, (long)clrPanelBorder);

   ObjectSetInteger(0, g_panel, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, g_panel, OBJPROP_SELECTED, true);

   ObjectSetInteger(0, g_panel, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panel, OBJPROP_HIDDEN, false);
}

void CreateText(string name, string text, color txtColor, int x, int y, int fontSize, bool bold)
{
   if(ObjectFind(0, name) == -1)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         Print("Text creation failed: ", name, " Error: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, iPanelX + x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, iPanelY + y);
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
