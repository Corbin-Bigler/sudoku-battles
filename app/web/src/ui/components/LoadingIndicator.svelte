<script lang="ts">
    export let size = 100;
    export let lineWidth = 8;
    export let color = "var(--color-purple-400)";

    function generateCirclePath(cx: number, cy: number, radius: number) {
        const startX = cx + radius;
        const startY = cy;

        const path = `M ${startX},${startY} a ${radius},${radius} 0 1,0 ${-2 * radius},0 a ${radius},${radius} 0 1,0 ${2 * radius},0`;

        return path;
    }

    const path = `path('M0,0 H${10000} V${10000} H0 Z ${generateCirclePath(size / 2, size / 2, size / 2 - lineWidth)}')`;
</script>

<div class="spinner" style="width: {size}px; height: {size}px;">
    <svg
        xmlns="http://www.w3.org/2000/svg"
        version="1.1"
        viewBox="0 0 {100 - 8 + lineWidth} {100 - 8 + lineWidth}"
    >
        <path
            d="M4,50C4,24.6357422,24.6357422,4,50,4c18.2718271,0,34.0898243,10.7087735,41.5073204,26.1796493,2.8791908,6.0052075,4.4926796,12.7279201,4.4926796,19.8203507,0,9.7338535-3.0391028,18.7713208-8.2182613,26.213355"
            fill="none"
            stroke={color}
            stroke-linecap="round"
            stroke-miterlimit="10"
            stroke-width={lineWidth}
            transform="translate({(lineWidth - 8) / 2}, {(lineWidth - 8) / 2})"
        />
    </svg>
</div>

<style>
    .spinner {
        animation: spin 2s linear infinite;
        mask-image: conic-gradient(
            from 130deg,
            rgba(0, 0, 0, 0) 130deg,
            rgba(0, 0, 0, 1) 360deg
        );
        mask-repeat: no-repeat;
        mask-size: 100%;
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
</style>
