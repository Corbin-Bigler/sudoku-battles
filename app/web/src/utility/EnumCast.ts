export default function enumCast<T extends Record<string, string>>(
    enumType: T,
    value: unknown
): T[keyof T] | null {
    return Object.values(enumType).includes(value as T[keyof T])
        ? (value as T[keyof T])
        : null;
}