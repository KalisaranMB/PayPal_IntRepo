export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'intent',
        label: 'Intent',
        initialWidth: 300,
    },
    {
        type: 'text',
        fieldName: 'date',
        label: 'Date',
    },
    {
        type: 'text',
        fieldName: 'lastModifiedBy',
        label: 'Last Modified By',
    },
    {
        type: 'text',
        fieldName: 'status',
        label: 'Status',

    },
    {
        type: 'url',
        fieldName: 'details',
        label: 'Details',
        typeAttributes: {
            label: { fieldName: 'detailsLabel' },
        }
    },
];

/**
 * Sample data
 * :: used by examples
 */
export const EXAMPLES_DATA_BASIC = [
    {
        intent: 'Password Reset',
        date: '02-03-2020 00:01',
        lastModifiedBy: "Ravi Kishore Anchala",
        status: 'Completed',
        details: 'http://salesforce.com/fake/url/jane-doe',
        detailsLabel:'I-31001'
    },

    {
        intent: 'Add Card',
        date: '02-03-2020 00:01',
        lastModifiedBy: "Ravi Kishore Anchala",
        status: 'Completed',
        details: 'http://salesforce.com/fake/url/jane-doe',
        detailsLabel:'I-31001',
        _children: [
            {
                intent: 'Confirm Address',
                date: '02-03-2020 00:01',
                lastModifiedBy: "Ravi Kishore Anchala",
                status: 'Completed',
                details: 'http://salesforce.com/fake/url/jane-doe',
                detailsLabel:'I-31009'
            },
            {
                intent: 'Add Card',
                date: '02-03-2020 00:01',
                lastModifiedBy: "Ravi Kishore Anchala",
                status: 'Completed',
                details: 'http://salesforce.com/fake/url/jane-doe',
                detailsLabel:'I-31001'
            }
        ],
    },

    {
        intent: 'Selling Fee',
        date: '02-03-2020 00:01',
        lastModifiedBy: "Ravi Kishore Anchala",
        status: 'Completed',
        details: 'http://salesforce.com/fake/url/jane-doe',
        detailsLabel:'I-31003',
        _children: [
            {
                intent: 'Password Reset',
                date: '02-03-2020 00:01',
                lastModifiedBy: "Ravi Kishore Anchala",
                status: 'Completed',
                details: 'http://salesforce.com/fake/url/jane-doe',
                detailsLabel:'S-31002'
            },
        ],
    },

    {
        intent: 'Password Reset',
        date: '02-03-2020 00:01',
        lastModifiedBy: "Ravi Kishore Anchala",
        status: 'Completed',
        details: 'http://salesforce.com/fake/url/jane-doe',
        detailsLabel:'I-31004',
        _children: [
            {
                intent: 'Password Reset',
                date: '02-03-2020 00:01',
                lastModifiedBy: "Ravi Kishore Anchala",
                status: 'Completed',
                details: 'http://salesforce.com/fake/url/jane-doe',
                detailsLabel:'S-31003'
            },
        ],
    },
];