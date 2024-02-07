
function getErrStack(instance, name, stack, code) {
    var result = "";
    var cutOne = instance.split("CDATA[")[1];
    if (cutOne) {
        var msg = "";
        var cutTwo = cutOne.split(".A 400")[0]
        var loopErr = cutTwo.split(".");
        for (var i = 0; i < loopErr.length; i++) {
            const element = loopErr[i];
            if (element) {
                msg = msg + "<err><message>" + element + "</message></err>";
            }
        }
        result = "<result><stack>" + stack + "</stack><code>" + code + "</code><name>" + name + "</name>" + msg + "</result>"
    } else {
        result = "<result><stack>" + stack + "</stack><code>" + code + "</code><name>" + name + "</name>" +  "<err><message>" + instance + "</message></err>" + "</result>"
    }
    return result;
}

//FulfillLineEffBOCS_GL_OCprivateVO


//SourceTransactionSystem: Mandarlo en duro
//TransactionType: Tienda en linea buscar en 905
//TransactionalCurrencyName: Mandar nombre de moneda no codigo
//RequestingBusinessUnitName: BU del cliente


//El nuevo flex debe de llevar el CustomerPONumber
