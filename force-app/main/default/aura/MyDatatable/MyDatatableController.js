({
    init : function(component, event, helper) {
        const data = [
            { id: '1', FirstName: 'Rose', LastName: 'Gonzalez', Phone: '(512) 757-6000', Email: 'rose@edge.com' },
            { id: '2', FirstName: 'Sean', LastName: 'Forbes', Phone: '(512) 757-6000', Email: 'sean@edge.com' },
            { id: '3', FirstName: 'Jack', LastName: 'Rogers', Phone: '(336) 222-7000', Email: 'jrogers@burlington.com' },

        ];

        const columns = [
            { label: 'First Name', fieldName: 'FirstName', type: 'text' },
            { label: 'Last Name', fieldName: 'LastName', type: 'text' },
            { label: 'Phone', fieldName: 'Phone', type: 'phone' },
            { label: 'Email', fieldName: 'Email', type: 'email' }
        ];

        component.set("v.myData", data);
        component.set("v.myColumns", columns);
    }
})