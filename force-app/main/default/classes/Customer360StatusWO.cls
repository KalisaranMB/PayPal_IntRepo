public class Customer360StatusWO {
    @AuraEnabled
    public String status;

    @AuraEnabled
    public String message;

    @AuraEnabled
    public List<String> unavailableDataList;

    @AuraEnabled
    public String debugId;

    public Customer360StatusWO()
    {
        status = Customer360.Status.FAILURE.name().toUpperCase();
        message = '';
        unavailableDataList = new List<String>();
        debugId = ExecutionContextUtil.getPayPalCorrelationId();
    }

    public void setStatus(Customer360.Status res)
    {
        if (res != null)
        {
            status = res.name().toUpperCase();
        }
    }

    public void setMessage(String msg)
    {
        message = msg;
    }

    public void setStatusAndMessage(Customer360.Status res, String msg)
    {
        if (res != null)
        {
            status = res.name().toUpperCase();
            message = msg;
        }
    }

    public void addMissingDataPoints(String missingData)
    {
        if (String.isNotBlank(missingData))
        {
            unavailableDataList.add(missingData);
        }
    }

}