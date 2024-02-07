const oracledb = require("oracledb");
let clientOpts = { libDir: "C:\\Oracle\\instantclient_21_8" };
const chalk = require("chalk");
const axios = require("axios");
const host = "https://eqjz.ds-fa.oraclepdemos.com";
const user = "SCM_IMPL";
const pass = "E^8A2?Sn";
const basicAuth = 'Basic ' + btoa(user + ':' + pass);
const fields = '?limit=100'


function toLower(text) {
    if (text.includes("_")) {
        let spl = text.split("_");
        let label = "";
        for (let i = 0; i < spl.length; i++) {
            const element = spl[i];
            if (i === 0) {
                label = label + element.toLowerCase();
            } else {
                label = label + capitalizarPrimeraLetra(element)
            }
        }
        return label;
    } else {
        return text.toLowerCase();
    }
}
function capitalizarPrimeraLetra(str) {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}
function rowFormat(rows, many, isLogin) {
    if (many) {
        let dataRow = [];
        for (let j = 0; j < rows.rows.length; j++) {
            const elementActual = rows.rows[j];
            let dataObj = new Object();
            for (let i = 0; i < elementActual.length; i++) {
                const element = elementActual[i];
                const header = rows.metaData[i].name;
                if (header !== "PASSWORD") {
                    dataObj[toLower(header)] = element === "Y" ? true : element === "N" ? false : element;
                }
            }
            dataRow.push(dataObj);
        }
        return dataRow;
    } else if (rows.rows?.length === 0) {
        return many ? [] : {};
    } else {
        let data = rows.rows[0];
        let dataObj = new Object();
        for (let i = 0; i < data.length; i++) {
            const element = data[i];
            const meta = rows.metaData[i].name;
            if (meta !== "PASSWORD" || isLogin) {
                dataObj[toLower(meta)] = element === "Y" ? true : element === "N" ? false : element;
            }
        }
        return dataObj;
    }
}

async function insertData(con, data) {
    let inser = 'INSERT INTO ITG_DOO_HEADER_ALL (SOURCE_TRANSACTION_NUMBER,SOURCE_TRANSACTION_SYSTEM,BUSINESS_UNIT_NAME,BUYING_PARTY_NAME,BUYING_PARTY_CONTACT_NAME,TRANSACTION_TYPE,REQUESTED_SHIP_DATE,TRANSACTIONAL_CURRENCY_NAME,CUSTOMER_PO_NUMBER,PAYMENT_TERMS,STATUS,REQUESTED_FULFILLMENT_ORGANIZATION_NAME) VALUES(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)';
    let result = await con.execute(inser, [
        Date.now(),
        data.system,
        data.bu,
        data.cliente,
        data.contact,
        data.transaction,
        data.requestDate,
        data.currency,
        data.po,
        data.paymenTerm,
        'ON_AWAIT',
        data.org
    ], {
        autoCommit: true
    });
    let inserted = await getInsert(result.lastRowid, con);
    console.log(chalk.blue("INFO: ") + chalk.green("row header inserted with ID " + inserted.idHeader));
    return inserted.idHeader;
}
async function insertLines(conn, binds) {
    let otroSql = 'INSERT INTO ITG_DOO_LINES (ID_HEADER,PRODUCT_NUMBER,UNIT_SELLING_PRICE,ORDERED_QUANTITY,ORDERED_UOM_CODE,CREATE_BY,LAST_UPDATE_BY) VALUES(:a,:b,:c,:d,:e,:g,:h)';
    return await conn.executeMany(otroSql, binds, { autoCommit: true });
}

async function getInsert(rowId, conn) {
    let sql = `SELECT * FROM ITG_DOO_HEADER_ALL WHERE ROWID = '${rowId}'`;
    let result = await conn.execute(sql);
    return rowFormat(result, false, false);
}
async function getDataErp() {
    let config = {
        method: 'get',
        maxBodyLength: Infinity,
        url: `${host}/fscmRestApi/resources/latest/salesOrdersForOrderHub${fields}`,
        headers: {
            'Authorization': basicAuth
        }
    };
    let result = await axios.request(config);
    return result.data;
}


(async () => {
    try {
        oracledb.initOracleClient(clientOpts);
        const conn = await oracledb.getConnection({
            user: "ADMIN",
            password: "$FBHp94DEyUq2",
            connectionString: "d8ddqi5zlatji9am_high",
        });
        let result = await conn.execute("select * from v$version");
        let row = result?.rows[0];
        console.log(chalk.blue("INFO: ") + chalk.green("Connection to " + row[0] + " successfully"));
        /********************INSERT DATA*************************************/
        const { items } = await getDataErp()
        for (let i = 0; i < items.length; i++) {
            const element = items[i];
            const lines = element?.lines;
            let binds = [];
            let objSend = {
                system: element.SourceTransactionSystem,
                bu: element.BusinessUnitName,
                cliente: element.BuyingPartyName,
                contact: element.BuyingPartyContactName,
                transaction: element.TransactionType,
                requestDate: element.RequestedShipDate,
                currency: element.TransactionalCurrencyName,
                po: element.CustomerPONumber,
                paymenTerm: element.PaymentTerms,
                org: element.RequestedFulfillmentOrganizationName
            };
            let id = await insertData(conn, objSend);
            for (let j = 0; j < lines?.length; j++) {
                const line = lines[j];
                binds.push({
                    a: id,
                    b: line.ProductNumber,
                    c: line.UnitSellingPrice,
                    d: line.OrderedQuantity,
                    e: line.OrderedUOMCode,
                    g: "SYSTEM",
                    h: "SYSTEM"
                })
            }
            let ins = await insertLines(conn, binds);
            console.log(chalk.yellow("SSR: ")+chalk.cyan("Lines inserted - "+ins.rowsAffected + " OK"))
        }

    } catch (error) {
        console.log(error)
    }
})()

//https://fa-etaj-saasfademo1.ds-fa.oraclepdemos.com/