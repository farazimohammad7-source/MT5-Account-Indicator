#property copyright "Copilot"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input int iXOffset = 20;
input int iYOffset = 25;

string g_balance = "BalanceLabel";
string g_equity  = "EquityLabel";
string g_profit  = "ProfitLabel";

int OnInit()
{
   CreateText(g_balance, "Balance: --", clrDodgerBlue, 0);
   CreateText(g_equity,  "Equity: --",  clrSilver, 22);
   CreateText(g_profit,  "P/L: --",     clrLimeGreen, 44);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteObject(g_balance);
   DeleteObject(g_equity);
   DeleteObject(g_profit);
}

void OnTimer()
{
   UpdateInfo();
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
   UpdateInfo();
   return(rates_total);
}

void UpdateInfo()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit  = AccountInfoDouble(ACCOUNT_PROFIT);
   string currency = AccountInfoString(ACCOUNT_CURRENCY);

   ObjectSetString(0, g_balance, OBJPROP_TEXT, "Balance: " + DoubleToString(balance,2) + " " + currency);
   ObjectSetString(0, g_equity,  OBJPROP_TEXT, "Equity:  " + DoubleToString(equity,2) + " " + currency);
   ObjectSetString(0, g_profit,  OBJPROP_TEXT, "P/L:     " + DoubleToString(profit,2) + " " + currency);
}

void CreateText(string name, string text, color c, int yOffset)
{
   if(ObjectFind(0, name) == -1)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, iXOffset);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, iYOffset + yOffset);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (long)c);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Tahoma");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
}

void DeleteObject(string name)
{
   if(ObjectFind(0, name) != -1)
      ObjectDelete(0, name);
}
