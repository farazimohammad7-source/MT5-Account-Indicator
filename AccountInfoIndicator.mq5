#property copyright "Copilot"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input string sFontName = "Tahoma";
input int    iFontSize = 12;
input int    iXOffset = 20;
input int    iYOffset = 20;

input bool   bShowPanel = true;
input bool   bShowBackground = true;

input color  clrPanelBack = C'18,18,18';
input color  clrPanelBorder = C'80,120,255';
input color  clrTitle = clrWhite;
input color  clrBalance = clrDodgerBlue;
input color  clrEquity = clrSilver;
input color  clrProfit = clrLimeGreen;
input color  clrLoss = clrTomato;

input int    iPanelWidth = 220;
input int    iPanelHeight = 112;

string g_panel = "MT5_Account_Panel";
string g_title = "MT5_Account_Title";
string g_balance = "MT5_Account_Balance";
string g_equity = "MT5_Account_Equity";
string g_profit = "MT5_Account_Profit";

int OnInit()
{
   CreatePanel();
   CreateText(g_title, "ACCOUNT INFO", clrTitle, 10, 8, 12);
   CreateText(g_balance, "Balance: --", clrBalance, 10, 32, iFontSize);
   CreateText(g_equity,  "Equity: --",  clrEquity,  10, 55, iFontSize);
   CreateText(g_profit,  "P/L: --",     clrProfit, 10, 78, iFontSize);

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

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   UpdateAccountInfo();
   return(rates_total);
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

   ObjectSetInteger(0, g_panel, OBJPROP_XDISTANCE, iXOffset);
   ObjectSetInteger(0, g_panel, OBJPROP_YDISTANCE, iYOffset);
   ObjectSetInteger(0, g_panel, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_panel, OBJPROP_XSIZE, iPanelWidth);
   ObjectSetInteger(0, g_panel, OBJPROP_YSIZE, iPanelHeight);
   ObjectSetInteger(0, g_panel, OBJPROP_BGCOLOR, bShowBackground ? (long)clrPanelBack : (long)clrNONE);
   ObjectSetInteger(0, g_panel, OBJPROP_COLOR, (long)clrPanelBorder);
   ObjectSetInteger(0, g_panel, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panel, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_panel, OBJPROP_HIDDEN, false);
}

void CreateText(string name, string text, color txtColor, int x, int y, int fontSize)
{
   if(ObjectFind(0, name) == -1)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         Print("Text creation failed: ", name, " Error: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, iXOffset + x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, iYOffset + y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (long)txtColor);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, sFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

void DeleteObject(string name)
{
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
}
