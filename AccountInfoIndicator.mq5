#property copyright "Copilot"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color clrBalance = clrDodgerBlue;
input color clrEquity = clrDarkGray;
input color clrProfit = clrForestGreen;
input color clrLoss = clrFireBrick;
input string sFontName = "Tahoma";
input int    iFontSize = 11;
input int    iXOffset = 20;
input int    iYOffset = 30;
input bool   bShowBackground = true;
input bool   bShowProfitText = true;

string g_prefix = "MT5_AccountInfo_";
string g_balance = g_prefix + "Balance";
string g_equity = g_prefix + "Equity";
string g_profit = g_prefix + "Profit";

int OnInit()
{
   CreateLabel(g_balance, "Balance: --", clrBalance, iXOffset, iYOffset);
   CreateLabel(g_equity, "Equity: --", clrEquity, iXOffset, iYOffset + 22);
   CreateLabel(g_profit, "P/L: --", clrProfit, iXOffset, iYOffset + 44);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteLabel(g_balance);
   DeleteLabel(g_equity);
   DeleteLabel(g_profit);
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

void OnTimer()
{
   UpdateAccountInfo();
}

void UpdateAccountInfo()
{
   double balance = AccountBalance();
   double equity = AccountEquity();
   double profit = AccountProfit();
   string currency = AccountCurrency();

   string balanceText = "Balance: " + DoubleToString(balance, 2) + " " + currency;
   string equityText  = "Equity:  " + DoubleToString(equity, 2) + " " + currency;

   string plText = "P/L: " + DoubleToString(profit, 2) + " " + currency;
   color plColor = (profit >= 0) ? clrProfit : clrLoss;

   if(bShowProfitText == false)
      plText = "";

   ObjectSetString(0, g_balance, OBJPROP_TEXT, balanceText);
   ObjectSetInteger(0, g_balance, OBJPROP_COLOR, clrBalance);

   ObjectSetString(0, g_equity, OBJPROP_TEXT, equityText);
   ObjectSetInteger(0, g_equity, OBJPROP_COLOR, clrEquity);

   ObjectSetString(0, g_profit, OBJPROP_TEXT, plText);
   ObjectSetInteger(0, g_profit, OBJPROP_COLOR, plColor);
}

void CreateLabel(string name, string text, color clr, int x, int y)
{
   if(ObjectFind(0, name) == -1)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         Print("Failed to create label: ", name, " Error: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_FONT, sFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bShowBackground ? clrBlack : clrNONE);
   ObjectSetDouble(0, name, OBJPROP_ANGLE, 0.0);
}

void DeleteLabel(string name)
{
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
}
