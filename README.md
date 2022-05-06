# Trading Expert Advisor

## Regras/Rules

Desenvolver em MQL5 um agente de negociação para realizar compra e venda de ações.

### Para isso, o agente de negociação deve ter como estratégia de compra:
- A partir de duas médias móveis (uma lenta e uma rápida), identificar quando a média móvel rápida cruza para cima da média móvel lenta;
- Volume crescente de negociação;
- O preço do ativo não deve estar em região de sobrecompra.

### A política de venda deve seguir os critérios abaixo:
- A partir de duas médias móveis (uma lenta e uma rápida), identificar quando a média móvel rápida cruza para baixo da média móvel lenta;
- Volume decrescente de negociação;
- Se achar interessante, considerar regiões de sobrecompra.

Atenção: neste trabalho não deverá ser utilizado stop loss e nem take profit (stop gain).

## Testes/Tests

Para testar a implementação, você deverá executar backtests somente com os dados de 2022 dos seguintes ativos: B3SA3, RRRP3 e ITUB4.
