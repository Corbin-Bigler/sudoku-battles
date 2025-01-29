<script>
    import RouteState from "../../state/RouteState";
</script>

<div>
    <h1>Inner Child page</h1>
    <button on:click={()=>{RouteState.navigate("/inner")}} >Back</button>
</div>