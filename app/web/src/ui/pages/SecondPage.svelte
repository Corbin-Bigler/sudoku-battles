<script>

    import RouteState from "../state/RouteState";

</script>
<div>
    <h1>Second Page</h1>
    <button on:click={()=>{RouteState.navigate("/")}} >Back</button>
</div>