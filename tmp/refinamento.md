# Refinamento


1. Na primeira entrada de abastecimento não é necessário validar o campo `caixaDisponivel`, pois o objeto caixa ainda não foi criado.
2. Se houver a entrada 1 (criação) e a 2 com sucesso, sem levantar exceção, a saída 2 não é o estado atual do caixa, e sim o abastecimento da entrada. Entendo que ainda sim preciso fazer a soma no objeto caixa em memória
3. Parece que as entradas não são sequencias: abastecimento > saque, pois sendo assim não seria possível tentar sacar e cair no cenário `caixa-inexistente`
4. Se ao criar o objeto caixa com o 1º abastecimento eu passar o atributo `caixaDisponivel` como `true`, a segunda vez que o usuário for depositar vai levantar a exceção de `caixa-em-uso`. O problema é que isso vai cair num loop infinito, se o objeto nascer com esse valor como verdadeiro. Se na segunda tentativa de deposito levantar erro pois o que foi observado foi o atributo atual do objeto, devo dar rollback apenas no depósito das cédulas e alterar a flag `caixaDisponivel`. Se isso não for feito o loop infinito vai ocorrer.
5. Se houvesse na funcionalidade 1 um cenário com dois abastecimentos, o primeiro iniciando com o caixa disponível para saque o segundo indisponível iria me ajudar no entendimento.