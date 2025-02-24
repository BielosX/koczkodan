
    export type RemoteKeys = 'payments/Payments';
    type PackageType<T> = T extends 'payments/Payments' ? typeof import('payments/Payments') :any;