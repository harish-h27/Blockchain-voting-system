import { Context } from 'fabric-contract-api'
import {RequiredType} from './declarations'
export async function getStateByKey(ctx: Context, key: string) {
    const result = await ctx.stub.getState(key)
    if (result.length > 0) JSON.parse(result.toString())
    return null;
}


export async function createCompositeKey(ctx: Context, params: string[]) {
    const firstElement = params.shift() as string
    const key = ctx.stub.createCompositeKey(firstElement, params);
    return key;
}
export function required(params: string[]) {
    let isExist = true;
    for (let i = 0; i < params.length; i++) {
        if (!params[i]) isExist = false;
    }
    return isExist;
}
// export async function required(ctx: Context, params: RequiredType) {
//     const keys = Object.keys(params);
//     let isExist = true;
//     for (let i = 0; i < keys.length; i++) {
//         const key = keys[i], value = params[key];
//         const ctxKey = await createCompositeKey(ctx, [key, ...value]);
//         const result = await getStateByKey(ctx, ctxKey);
//         if (result !== null) isExist = false;
//     }

// } 

/*
{key: value}

{VOTE: V1}



*/