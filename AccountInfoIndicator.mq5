#property copyright "Copilot"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input string sFontName = "Tahoma";
input int    iFontSize = 12;
input int    iXOffset = 20;
input int    iYOffset = 25;
input bool   bShowBackground = true;
input color  clrBackground = clrBlack;
input color  clrBalance = clrDodgerBlue;
input color  clrEquity = clrLightGray;
input color  clrProfit = clrLimeGreen;
input color  clrLoss = clrTomato;

string g_balanceLabel = "MT5_Balance_Label";
string g_equityLabel  = "MT5_Equity_Label";
string g_profitLabel  = "MT5_Profit_Label";

int OnInit()
{
   CreateLabel(g_balanceLabel, "Balance: --", clrBalance, 0);
   CreateLabel(g_equityLabel,  "Equity: --",  clrEquity,  25);
   CreateLabel(g_profitLabel,  "P/L: --",     clrProfit,  50);

   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteLabel(g_balanceLabel);
   DeleteLabel(g_equityLabel);
   DeleteLabel(g_profitLabel);
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
   string profitText  = "P/L: " + DoubleToString(profit, 2) + " " + currency;

   color profitColor = (profit >= 0) ? clrProfit : clrLoss;

   ObjectSetString(0, g_balanceLabel, OBJPROP_TEXT, balanceText);
   ObjectSetInteger(0, g_balanceLabel, OBJPROP_COLOR, clrBalance);

   ObjectSetString(0, g_equityLabel, OBJPROP_TEXT, equityText);
   ObjectSetInteger(0, g_equityLabel, OBJPROP_COLOR, clrEquity);

   ObjectSetString(0, g_profitLabel, OBJPROP_TEXT, profitText);
   ObjectSetInteger(0, g_profitLabel, OBJPROP_COLOR, profitColor);
}

void CreateLabel(string name, string text, color labelColor, int yOffset)
{
   if(ObjectFind(0, name) == -1)
   {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         Print("Failed to create label: ", name, " Error: ", GetLastError());
         return;
      }
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, iXOffset);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, iYOffset + yOffset);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, labelColor);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, sFontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   if(bShowBackground)
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBackground);
   else
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrNONE);
}

void DeleteLabel(string name)
{
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
}
