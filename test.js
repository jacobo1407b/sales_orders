function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}
let ui = generateUUID();
console.log(ui);
console.log(ui.length)

//oj-ux-ico-warning-s   --------ERROR
//oj-ux-ico-calendar-clock -----ON_AWAIT
//oj-ux-ico-send ---------------AWAIT_SHIPPING
//oj-ux-ico-vendor-bill --------AWAIT_BILLING