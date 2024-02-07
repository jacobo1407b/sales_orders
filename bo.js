const { writeFileSync, readFileSync } = require("fs")
const axios = require("axios");
const hostERP = "https://eqjz.ds-fa.oraclepdemos.com";
const userERP = "SCM_IMPL";
const passERP = "E^8A2?Sn";
const basicAuthERP = 'Basic ' + btoa(userERP + ':' + passERP);
const fields = '?limit=100';



async function getData() {
    let config = {
        method: 'get',
        maxBodyLength: Infinity,
        url: `${hostERP}/fscmRestApi/resources/11.13.18.05/unitsOfMeasure${fields}`,
        headers: {
            'Authorization': basicAuthERP
        }
    };
    let result = await axios.request(config);
    return result.data;
}

(async () => {
    //let dataRead = readFileSync("C:\\Users\\omy-m\\Downloads\\UOM.csv", { encoding: "utf-8" });
    //console.log(dataRead.split("\r\n"))
    let data = await getData();
    let fullData = "";
    let headers = "id,creationDate,lastUpdateDate,createdBy,lastUpdatedBy,uOMCode,uOM"
    fullData = fullData + headers + "\r\n";
    for (let i = 0; i < data.items.length; i++) {
        const element = data.items[i];
        let srt = `,,,,,${element.UOMCode},${element.UOM}`;
        fullData = fullData + srt + "\r\n";
    }
    writeFileSync("./UOM.csv", fullData, { encoding: "utf-8" })

})()

//uOMCode
//uOM