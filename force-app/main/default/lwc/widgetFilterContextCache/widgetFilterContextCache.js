const context = {
    startDateName: 'startDateWidgetContext',
    get startDate() {
        let dateStr = sessionStorage.getItem(this.startDateName + this.id);
        if(!dateStr){
            let d = new Date();
            d.setDate(d.getDate() - 5);
            dateStr = d.toISOString();
        }
        return dateStr;
    },
    set startDate(d) {
        sessionStorage.setItem(this.startDateName + this.id, d);
    },

    endDateName: 'endDateWidgetContext',
    get endDate() {
        let dateStr = sessionStorage.getItem(this.endDateName + this.id);
        if(!dateStr){
            dateStr = new Date().toISOString();
        }
        return dateStr;
    },
    set endDate(d) {
        sessionStorage.setItem(this.endDateName + this.id, d);
    },

    dateFilterTypeName: 'dateFilterTypeWidgetContext',
    get dateFilterType() {
        return sessionStorage.getItem(this.dateFilterTypeName + this.id);
    },
    set dateFilterType(type) {
        sessionStorage.setItem(this.dateFilterTypeName + this.id, type);
    },

    idName: 'idWidgetContext',
    get id() {
        return sessionStorage.getItem(this.idName);
    },
    set id(i) {
        sessionStorage.setItem(this.idName, i);
    }
}

export {
    context
}