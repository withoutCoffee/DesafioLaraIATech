#Teste de request no yahoo finace api 

#install.packages("rvest")
#install.packages("lubridate")
#install.packages("quantmod")
#install.packages("tidyquant")

library(rvest)
library(tidyquant)
library(ggplot2)
library(patchwork)
library(tibble)

library("lubridate")

tickers = c("AAPL", "AMZN", "INTC", "GOOG", "CSCO")

profile_url = 'https://finance.yahoo.com/quote/#/profile?p=#'
#fpurl = gsub('#',tickers[1],profile_url)

replace_url = function(name){
  return(gsub('#',name,profile_url))
}
get_company_data = function(name){
  # Capturar principais informações da empresa
  
  company_data = list()
  
  #replace na url, add ticker
  fpurl = replace_url(name)
  
  cname = read_html(fpurl) %>%
    html_elements("h3") %>%
    html_text()#[7]
  
  #Adicionando nome da empresa
  company_data = append(company_data,list(Company_Name=cname[7]))
  
  # Endereço da empresa html->texto
  address = read_html(fpurl) %>%
    html_element(xpath = "//div[@class='Mb(25px)']/p[1]") %>%
    html_text2()
  
  # address split -> street, city-state-number, country, phone 
  address = strsplit(address,split = "\n")
  country = address[[1]][3]
  street = address[[1]][1]
  phone = address[[1]][4]
  city = strsplit(address[[1]][2],split = ",")[[1]][1]
  state = strsplit(strsplit(address[[1]][2],",")[[1]][2],split=" ")[[1]][2]
  number = strsplit(strsplit(address[[1]][2],",")[[1]][2],split=" ")[[1]][3]
  
  company_data = append(company_data,list(
    Street=street,
    City=city,
    State=state,
    Number=number,
    Country=country,
    Phone=phone
    ))
  
  # Informações adicionais html->texto
  extra = read_html(fpurl) %>%
    html_element(xpath = "//div[@class='Mb(25px)']/p[2]") %>%
    html_text2()
  # Split
  extra = strsplit(extra,split="\n")[[1]]
  extra = strsplit(extra,split=": ")
  
  sector = extra[[1]][2]
  industry = extra[[2]][2]
  employers = strtoi(gsub(",","",extra[[3]][2]))
  
  company_data = append(company_data,list(
    Sector=sector,
    Industry=industry,
    Employers=employers
  ))
  return(data.frame(company_data))
}

get_employers = function(name){
  # Capturar lista de pricipais funcionários do tickers
  
  # replace na url, add ticker
  fpurl = replace_url(name)
  #Key Executives
  employers = read_html(fpurl) %>%
    html_element("table") %>%
    html_table()
  return(data.frame(key_employers = employers$Name))
}
stock_prices_ticker = function(ticker){
  #Calculando 200 dias anteriores a hoje
  s_prices = tq_get(ticker,get = "stock.prices",from=today()-201,to=today()-1)
  return (s_prices)
}

get_lastday_month_price = function(ticker){
  # Preço fechamento do último dia do mês 200 dias anteriores
  
  table = stock_prices_ticker(ticker)
  xd = table$date[1]
  n = length(table$date)
  filtered_data = list()
  cl = c()
  vol = c()
  dates = c()
  for(j in 1:n){
    if(month(table$date[j])!=month(xd)){
      xd = table$date[j]
      
      cl =  append(cl,table$close[j-1])
      
      vol =  append(vol,table$volume[j-1])
      
      dates = append(dates,c(table$date[j-1]))
    }
    
  }
  filtered_data = list(date = dates,close=cl,volume=vol)
  return(data.frame(filtered_data))
}

#get_company_data(tickers[1])


# Plotagem dos preços de fechamento de cada ação
# par(mfrow=c(2,3))
# for(ticker in tickers){
#   filtered_data = get_lastday_month_price(ticker)
#   print(filtered_data)
#   # plot(x = filtered_data$date,y = filtered_data$close,
#   #      type = "b",
#   #      main = paste("Fechamento Último dia do mês:",ticker),
#   #      xlab = "Data",
#   #      ylab = "Preço fechamento")
#   info = get_employers(ticker)
#   print(get_company_data(ticker))
#   print(info)
# }

